---
ctime: 2023-01-31 16:24
tags: simlpe-card
author: lche
alias: pxf
---
#Greenplum #PXF #vault-squirreldoc 
## 01. INTRO
Platform Extension Framework(PXF)
- 定位: A Greenplum extension that provides ==parallel, high throughput data access== and ==federated query processing==
- 规格:
	- Perform queries on the external data, leaving the referenced data in place on the remote system.
	-  Load a subset of the external data into Greenplum Database.
	- Run complex queries on local data residing in Greenplum tables and remote data referenced via PXF external tables.
	- Write data to the external data source. 
	- external data
		- Hadoop (HDFS, Hive, HBase), 
		- object stores (Azure, Google Cloud Storage, MinIO, AWS S3, and Dell ECS)
		- SQL databases (via JDBC)
- Why PXF
	- cold、warm、hot.
		- how often the data is accessed: real-time or transactional (hot), less frequent(warm), or archival (cold).
			![](https://docs.vmware.com/en/VMware-Tanzu-Greenplum-Platform-Extension-Framework/6.3/tanzu-greenplum-platform-extension-framework/Images/graphics-datatemp.png)
- External table
- PXF Vs FDW
	- PXF offers two advantages over FDW. 
		- First, PXF is able toonnect to many ==different external data sources==, including thoseon all the maior clouds, and can access data in various different formats. In contrast, 
		- Second, because PXF interfaces with Greenplum, it is able to ==access and write data in parallel== across Greenplum segments. 
## 02. Architecture 

![[Greenplum PXF 2023-02-03.excalidraw]]

- 3 Main components
	- PXF Extension
	- PXF Server
	- PXF CLi

- PXF Service / Service process
	- A single PXF Service process runs on each [[Greenplum.md#^00991d|gp database host]]
	- PXF service process running on a segment host. 
		- The PXF Service process running on a segment host allocates a ==worker thread== for ==each segment instance on the host== that participates in a ==query against an external table==. 
	-  The ==PXF Services== on multiple segment hosts communicate with the external data store in parallel.
## 03. Concepts
- Concepts
	- interfaces
		- Fragmenter
		- Accessor
		- Resolver
	- Logical concepts
		- Profile
		- Connector
#### Fragmenter
![[Greenplum PXF 2023-02-03_0.excalidraw]]
- A PXF ==Fragmenter== is a functional interface that splits the over all dataset from an external data source into a list of independent ==fragments== that can be read in parallel.
	- The fragmenter does not retrieve the actual data, it works only with metadata. 
		- The ==fragment metadata==, describes the location of a given data fragment and (optionally) the offset of the data within the overall dataset.
- Fragment.
	- Fragment is the smallest in-divisible chunk of data that is processed by a single PXF Server.
	- 如何在segments间分配?
		- modulo-based round-robin.
	- segments如何处理fragment
		-  dividing fragment evenly and fairly among GP servers.
			-  This is achieved by having ==all Green-plum segments determine the overall workload via the fragmentation call to, and then applying a modulo-based hashing function to the set of fragment metadata to determine which subset of fragments the given process has to work on.== 
		- Each segment iterates over the assigned subset of fragment
			- perform bridge call to read the actual data
				- during bridge call ^3611a2
					- PXF server, 
						- receive fragment metadata from segment
						- fetching data from external system using Accessor
- Fragmentation.
	-  The process of retrieving the set of fragment metadata is called fragmentation
- REST calls
	- Each Greenplum segment performs two types of REST calls to the PXF Server during the query against a PXF external table. 
		- A single fragmentation call followed by 
		- zero or more bridge calls. 
- Fragmentaion calls.
	- During the fragmentation call, the fragmenter divides up the overall dataset on the external system into fragments or chunks of data, along with metadata about each fragment. 
- Bridge calls. [[Greenplum PXF Architecture and Concepts#^3611a2]]

#### Accessor
- Accessor is a functional interface that is responsible for 
	- reading or writing data from/to external data sources,
	- converting data into individual records.
- How to retrieve data for a specific fragment
	- first fetches the configuration of the external data source. 
	- Next, it analyses the metadata for the requested fragment, and uses the client API libraries for its corresponding protocol to request the required data from the external data source.
	- 原始数据到record, The data it reads is broken it into records, such as lines of a text file, rows in a JDBC result set, or Parquet records, to name a few.
		- wrap into command data structure. Each such record, while still being in a proprietary format, is then wrapped into a common data structure that is used across PXF to exchange data.
- ==the accessor is also responsible for pushing down predicates and projecting columns from the in-coming query.== 
#### Resolver
Resolver is a functional interface that decodes (when read-ing) or encodes (when writing) the ==record read from/to the external system== by an accessor into individual fields.

#### Profile
- Profile is a simple named mapping that represents both 
	- the ==protocol== for connecting to an external data source 
	- the ==format== of the data that needs to be processed.
	- For example,
		- to read text file from S3 cloud storage, a user specifies the profile s3:text, 
		-  reading a parquet file from HDFS requires the hdfs:parquet profle.
- At runtime, PXF receives the value of the profile parameter with the request for data from Greenplum and refers to the PXF system configuration to select the appropriate Fragmenter, Accessor, and Resolver implementations for data retrieval and processing.

#### Connector
A Connector is a logical grouping of multiple components (fragmenters, accessors, resolvers, and profiles) that enables users to process data from a given type of external data source. 


- Connectors, Servers, Profiles
	- Connector
		- encapsulates the implementation details required to ==read from or write to an external data store.==
		- PXF provides built-in connectors :
			- HDFS, Hive, HBase
			- object stores (Azure, Google Cloud Storage, MinIO, AWS S3, and Dell ECS), 
			- SQL databases (via JDBC).
	- Server
		- a named configuration for a connector.
		- A server definition provides the information required for PXF to access an external data source. 
			- This configuration information is data-store-specific, and may include ==server location, access credentials, and other relevant properties.== 
	- Profile
		-  *profile* is a named mapping identifying a specific data format or protocol supported by a specific external data store
		- PXF supports
			- text,
			- Avro,
			- JSON, 
			- RCFile,
			- Parquet,
			- SequenceFile, 
			- ORC data formats, 
			- and the JDBC protocol

## 04. Main Feature
#### Predicate Pushdown
- How to
	- gp master generate query plan tree, dispatched to segments,
		- external scan operator has scalar expression, denotes the predicate on which input tuples are pruned
	- To ensure correctness, 
		- PXF connectors ==convert a Greenplum predicate into a corresponding filter clause supported by the external system==
			- and ignore pushing predicates that are incompatible with the external system; deferring the processing of any additional fltering
![[Greenplum PXF 2023-02-06.excalidraw]]
#### Column Projection
#### Named queries
- what
	- dispatch the pre-define query to the remote server . 在remote data source/database执行预定义的SQL(pre-define queries in a text file
		- 在gp query中可以用类似view的方式, 引用预定义的查询中的数据.对于数据的查询, 被替换为text file中的SQL.
	- predicate push down, 支持Named query
		- PXF also wraps the query in an external statement so that it can apply optimizations such as column projection, predicate pushdown, and partition filtering.
	- 示例
```sql
-- sales.sql
SELECT c.name, c.city, o.month, sum (o.amount) AS total
FROM customers c JOIN orders o ON c.id = o.customer_id
GROUP BY c.name, c.city, o.month;

-- external table
CREATE READABLE EXTERNAL TABLE sales_summary
(name text, city text, month int, total int) LOCATION ('pxf://query: sales?PROFILE= JdbC&SERVER=mysql-db’)
FORMAT " CUSTOM’ (formatter='pxfwritable_import'）;

-- query
SELECT * FROM sales_ summary WHERE city = "San Francisco';

-- warped sql clause and issuing query to remote database
SELECT name, city, month, total FROM C
	SELECT c.name, c.city, o.month, sum(o.amount) AS total
FROM customers c JOIN orders o ON c.id =o.customer_id
GROUP BY c.name, c.city, o.month) pxfsubquery
WHERE city = "San Francisco'
```
- why
	- avoid sql injection
	- 提供一种在remote server执行query的方式.(实现查询下推到 remote server)

#### PXF JDBC Read Partitioning

- what
	- a hint(like `PARTITION_ BY=month:int&RANGE=1:12`), telling pxf, dataset in remote database can be processed in parallel.
- 示例
```sql
-- sql in california_sales.sql
SELECT c.name, c.city, o.month,
sum(o.amount) As total, count (o.id) AS count
FROM customers c JoIN orders o ON c.id =o.customer_id
WHERE c. state = ' CALIFORNIA '
GROUP BY c.name, c.city, o.month

-- create external data 
CREATE READABLE EXTERNAL TABLE california_ sales
(name text, city text, month int, total int)
LOCATION ('pxf://query:california_sales?PROFILE=Jdbc&
SERVER=mySq1-db&PARTITION_BY=month: int&RANGE=1：12&INTERVAL=3”）
FORMAT ICUSTOM" (formatter="pxfwritable_import'）

-- query external table in gp
SELECT name, month, total FROM california_sales
WHERE city = San Francisco、
GROUP BY name, month, total
HAVING total > 100;

-- 1 query dispatched to remote database by PXF
SELECT name, city, month, total FROM (
SELECT c.name, c.city, o.month,
sum Co.amount) AS total, count (o.id) AS count
FROM customers c JOIN orders o oN c.id = o.customer_id
WHERE c.state = "CALIFORNIA '
GROUP BY c.name, c.city, o.month
pxfsubquery
WHERE city = "San Francisco' AND month >= 1 AND month < 4
```

#### Caching metadata information

#关联概念 
- [[Greenplum]]
- [[Highlights@articles@Introduction to PXF]]
- [[Highlights@articles@Greenplum Platform Extension Framework]]
- [[Highlights@articles@Platform Extension Framework (PXF) Enabling Parallel Query Processing Over Heterogeneous Data Sources in Greenplum]]