---
March 16, 2023
---
# 第2章 PostgreSQL的体系结构

![rw-book-cover](https://readwise-assets.s3.amazonaws.com/static/images/article2.74d541386bbf.png)

## Metadata
- Author: [[walleipt]]
- Full Title: 第2章 PostgreSQL的体系结构
- Category: #articles
- URL: https://walleipt.gitbooks.io/postgresql/content/di-2-zhang-postgresql-de-ti-xi-jie-gou.html

## Highlights
- PostgreSQL数据库由连接管理系统（系统控制器）、编译执行系统、存储管理系统、事务系统、系统表五大部分组成，其组成结构和关系如图2-1所示 ([View Highlight](https://read.readwise.io/read/01gvm3m33m56ckkdmemb8m1rne))
- 连接管理系统接受外部操作对系统的请求，对操作请求进行预处理和分发，起系统逻辑控制作用；编译执行系统由查询编译器、查询执行器组成，完成操作请求在数据库中的分析处理和转化工作，最终实现物理存储介质中数据的操作；存储管理系统由索引管理器、内存管理器、外存管理器组成，负责存储和管理物理数据，提供对编译查询系统的支持；事务系统由事务管理器、日志管理器、并发控制、锁管理器组成，日志管理器和事务管理器完成对操作请求处理的事务一致性支持，锁管理器和并发控制提供对并发访问数据的一致性支持；系统表是PostgreSQL数据库的元信息管理中心，包括数据库对象信息和数据库管理控制信息。系统表管理元数据信息，将PostgreSQL数据库的各个模块有机地连接在一起，形成一个高效的数据管理系统。 ([View Highlight](https://read.readwise.io/read/01gvm3nt3refcz2hqzmrfhx2w1))
- ![](http://images.51cto.com/files/uploadimg/20120118/2252350.jpg) ([View Highlight](https://read.readwise.io/read/01gvm3mdryc1xw5nfmrvcp72gv))
