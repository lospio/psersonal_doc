# 0. Installation
在安装Greenplum时，PXF已经安装了
PXF is installed on your master and segment nodes when you install Greenplum Database.
# 1. initialization
```bash
pxf cluster init
pxf init
```


![[Pasted image 20230131113101.png]]


# 操作步骤
```sql
CREATE EXTERNAL TABLE pxf_tt01(id int,name varchar)
            LOCATION ('pxf://public.tt01?PROFILE=Jdbc&SERVER=pg')
            FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
```
# 流程
```bash
**3763    ic_udpifc.c: No such file or directory.
(gdb) bt
#0  receiveChunksUDPIFC (pTransportStates=pTransportStates@entry=0x2d540f8, pEntry=pEntry@entry=0x3b3a468, motNodeID=motNodeID@entry=1, srcRoute=srcRoute@entry=0x7ffc71099cbe, conn=conn@entry=0x0) at ic_udpifc.c:3763
#1  0x0000000000c7cc22 in RecvTupleChunkFromAnyUDPIFC_Internal (srcRoute=0x7ffc71099cbe, motNodeID=1, transportStates=0x2d540f8) at ic_udpifc.c:3938
#2  RecvTupleChunkFromAnyUDPIFC (transportStates=0x2d540f8, motNodeID=1, srcRoute=0x7ffc71099cbe) at ic_udpifc.c:3958
#3  0x0000000000c71aae in processIncomingChunks (srcRoute=<optimized out>, motNodeID=1, pMNEntry=0x2ad05c8, transportStates=0x2d540f8, mlStates=0x2ad0528) at cdbmotion.c:660
#4  RecvTupleFrom (mlStates=<optimized out>, transportStates=0x2d540f8, motNodeID=1, srcRoute=srcRoute@entry=-100) at cdbmotion.c:616
#5  0x00000000008fc2f2 in execMotionUnsortedReceiver (node=0x2d679c0) at nodeMotion.c:425
#6  ExecMotion (node=node@entry=0x2d679c0) at nodeMotion.c:221
#7  0x00000000008bc458 in ExecProcNode (node=node@entry=0x2d679c0) at execProcnode.c:1121
#8  0x00000000008b3909 in ExecutePlan (estate=estate@entry=0x2d672e8, planstate=0x2d679c0, operation=operation@entry=CMD_SELECT, sendTuples=sendTuples@entry=1 '\001', numberTuples=numberTuples@entry=0, direction=direction@entry=ForwardScanDirection, dest=0x2c8f990)
    at execMain.c:2977
#9  0x00000000008b45ec in ExecutePlan (dest=0x2c8f990, direction=ForwardScanDirection, numberTuples=0, sendTuples=1 '\001', operation=CMD_SELECT, planstate=<optimized out>, estate=0x2d672e8) at execMain.c:2943
#10 standard_ExecutorRun (queryDesc=0x2ad00a8, direction=ForwardScanDirection, count=0) at execMain.c:1004
#11 0x0000000000a8a557 in PortalRunSelect (portal=0x2bc1d38, forward=<optimized out>, count=0, dest=<optimized out>) at pquery.c:1151
#12 0x0000000000a8c541 in PortalRun (portal=portal@entry=0x2bc1d38, count=count@entry=9223372036854775807, isTopLevel=isTopLevel@entry=1 '\001', dest=dest@entry=0x2c8f990, altdest=altdest@entry=0x2c8f990, completionTag=completionTag@entry=0x7ffc7109a180 "") at pquery.c:992
#13 0x0000000000a86b20 in exec_simple_query (query_string=0x2ac1fc8 "select * from pxf_tt02;") at postgres.c:1848
#14 0x0000000000a892dd in PostgresMain (argc=<optimized out>, argv=argv@entry=0x2aca850, dbname=<optimized out>, username=<optimized out>) at postgres.c:5266
#15 0x00000000006ac972 in BackendRun (port=0x2acc410) at postmaster.c:4828
#16 BackendStartup (port=0x2acc410) at postmaster.c:4485
#17 ServerLoop () at postmaster.c:1948
#18 0x0000000000a0df92 in PostmasterMain (argc=argc@entry=6, argv=argv@entry=0x2aa0a60) at postmaster.c:1518
#19 0x00000000006b08d1 in main (argc=6, argv=0x2aa0a60) at main.c:245
**

```
# 安装
```bash
yum install -y java-1.8.0-openjdk*
yum install ./pxf...
# 修改pxf-env.sh
pxf cluster register
pxf cluster sync

cd /etc/quark2/conf
docker cp core-site.xml a9e4372d1b25:/usr/local/pxf-gp6/servers/hdp3
docker cp hive-site.xml a9e4372d1b25:/usr/local/pxf-gp6/servers/hdp3


cp ../../template/pxf-site.xml ./
vi pxf-site.xml
#修pxf-site.xml pxf.service.kerberos.principal pxf.service.user.impersonation
pxf cluster sync

sudo yum install krb5-libs krb5-workstation -y

cp /etc/hdfs2/krb5.conf /etc/

docker exec -it -e COLUMNS=$(tput cols) -e LINES=$(tput lines) 9b20c260ac54 bash
kadmin.guardian -wadmin -rTDH -H172.18.120.27 -P8380 -T -q "addprinc -pw gpadmin gpadmin/gpdb"
kadmin.guardian -wadmin -rTDH -H172.18.120.27 -P8380 -T -q "addent -k /tmp/gpadmingpdb.keytab -p gpadmin/gpdb -pw gpadmin"

kadmin.guardian -wadmin -rTDH -H172.18.120.27 -P8380 -T -q "addprinc -pw gpadmin gpadmin/mdw"
kadmin.guardian -wadmin -rTDH -H172.18.120.27 -P8380 -T -q "addent -k /tmp/gpadminmdw.keytab -p gpadmin/mdw -pw gpadmin"


sudo chown -R gpadmin:gpadmin /usr/local/pxf-gp6/keytabs/pxf.service.keytab

sudo scp pxf.service.keytab sdw2:/usr/local/pxf-gp6/keytabs/

```