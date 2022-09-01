## 设置控制组

## 背景信息

openGauss资源负载管理的核心是资源池，而配置资源池首先要在环境中实现控制组Cgroups的设置。更多Cgroups的原理介绍，请查看相关操作系统的产品手册。openGauss的控制组请参考[查看控制组的信息](https://opengauss.org/zh/docs/2.1.0/docs/Developerguide/%E8%AE%BE%E7%BD%AE%E6%8E%A7%E5%88%B6%E7%BB%84.html#zh-cn_topic_0066854607_s66a16734a4e54c00abaaa1cc44c82c89)。

Class控制组为数据库业务运行所在的顶层控制组，集群部署时会自动生成默认子Class控制组“DefaultClass”。DefaultClass的Medium控制组会含有系统触发的作业在运行，该控制组不允许进行资源修改，且运行在该控制组上的作业不受资源管理的控制，所以推荐创建新的子Class及其Workload控制组来设置资源比例。

## 前提条件

已熟悉《工具参考》中“服务端工具 > gs\_cgroup”章节和“服务端工具 > gs\_ssh”章节的使用。

## 操作步骤

> ![](https://opengauss.org/zh/docs/2.1.0/docs/Developerguide/public_sys-resources/icon-note.gif) **说明：**
> 
> -   在openGauss中，需要在每个集群节点上执行控制组的创建、更新、删除操作，才能实现对整个集群资源的控制，所以下述步骤中都使用《工具参考》中“服务端工具 > gs\_ssh”命令执行。
>     
> -   控制组的命名要求如下：
>     
>     -   无论是子Class控制组还是Workload控制组，都不允许在名称中包含字符”：”。
>     -   不可以创建同名的控制组。

**创建子Class控制组和Workload控制组**

1.  以操作系统用户omm登录openGauss主节点。
2.  创建名称为“class\_a”和“class\_b”的子Class控制组，CPU资源配额分别为Class的40%和20%。
    
    ```
    复制代码gs_ssh -c "gs_cgroup -c -S class_a -s 40"
    
    ```
    
    ```
    复制代码gs_ssh -c "gs_cgroup -c -S class_b -s 20"
    
    ```
    
3.  创建子Class控制组“class\_a”下名称为“workload\_a1”和“workload\_a2”的Workload控制组，CPU资源配额分别为“class\_a”控制组的20%和60%。
    
    ```
    复制代码gs_ssh -c "gs_cgroup -c -S class_a -G workload_a1 -g 20 "
    
    ```
    
    ```
    复制代码gs_ssh -c "gs_cgroup -c -S class_a -G workload_a2 -g 60 "
    
    ```
    
4.  创建子Class控制组“class\_b”下名称为“workload\_b1”和“workload\_b2”的Workload控制组，CPU资源配额分别为“class\_b”控制组的50%和40%。
    
    ```
    复制代码gs_ssh -c "gs_cgroup -c -S class_b -G workload_b1 -g 50 "
    
    ```
    
    ```
    复制代码gs_ssh -c "gs_cgroup -c -S class_b -G workload_b2 -g 40 "
    
    ```
    

**更新控制组的资源配额**

1.  更新“class\_a”控制组的CPU资源配额为30%。
    
    ```
    复制代码gs_ssh -c "gs_cgroup -u -S class_a -s 30"
    
    ```
    
2.  更新“class\_a”下的“workload\_a1”的CPU资源配额为“class\_a”的30%。
    
    ```
    复制代码gs_ssh -c "gs_cgroup -u -S class_a -G workload_a1 -g 30"
    
    ```
    
    > ![](https://opengauss.org/zh/docs/2.1.0/docs/Developerguide/public_sys-resources/icon-notice.gif) **须知：** 调整后的Workload控制组“workload\_a1”占有的CPU资源不应大于其对应的子Class控制组“class\_a”。并且，此名称不能是Timeshare Cgroup的默认名称，如“Low”、“Medium”、“High”或“Rush”。
    

**删除控制组**

1.  删除控制组“class\_a”。
    
    ```
    复制代码gs_ssh -c "gs_cgroup -d  -S class_a"
    
    ```
    
    以上操作可以删除控制组“class\_a”。
    
    > ![](https://opengauss.org/zh/docs/2.1.0/docs/Developerguide/public_sys-resources/icon-notice.gif) **须知：** root用户或者具有root访问权限的用户指定“-d” 和“-U username”删除普通用户“username”可访问的默认Cgroups。普通用户指定“-d”和“-S classname”可以删除已有的Class Cgroups。
    

## 查看控制组的信息

1.  查看配置文件中控制组信息。
    
    ```
    复制代码gs_cgroup -p 
    
    ```
    
    控制组配置信息
    
    ```
    复制代码gs_cgroup -p
        
    Top Group information is listed:
    GID:   0 Type: Top    Percent(%): 1000( 50) Name: Root                  Cores: 0-47
    GID:   1 Type: Top    Percent(%):  833( 83) Name: Gaussdb:omm           Cores: 0-20
    GID:   2 Type: Top    Percent(%):  333( 40) Name: Backend               Cores: 0-20
    GID:   3 Type: Top    Percent(%):  499( 60) Name: Class                 Cores: 0-20
        
    Backend Group information is listed:
    GID:   4 Type: BAKWD  Name: DefaultBackend   TopGID:   2 Percent(%): 266(80) Cores: 0-20
    GID:   5 Type: BAKWD  Name: Vacuum           TopGID:   2 Percent(%):  66(20) Cores: 0-20
        
    Class Group information is listed:
    GID:  20 Type: CLASS  Name: DefaultClass     TopGID:   3 Percent(%): 166(20) MaxLevel: 1 RemPCT: 100 Cores: 0-20
    GID:  21 Type: CLASS  Name: class1           TopGID:   3 Percent(%): 332(40) MaxLevel: 2 RemPCT:  70 Cores: 0-20
        
    Workload Group information is listed:
    GID:  86 Type: DEFWD  Name: grp1:2           ClsGID:  21 Percent(%):  99(30) WDLevel:  2 Quota(%): 30 Cores: 0-5
        
    Timeshare Group information is listed:
    GID: 724 Type: TSWD   Name: Low              Rate: 1
    GID: 725 Type: TSWD   Name: Medium           Rate: 2
    GID: 726 Type: TSWD   Name: High             Rate: 4
    GID: 727 Type: TSWD   Name: Rush             Rate: 8
        
    Group Exception information is listed:
    GID:  20 Type: EXCEPTION Class: DefaultClass
    PENALTY: QualificationTime=1800 CPUSkewPercent=30
        
    GID:  21 Type: EXCEPTION Class: class1
    PENALTY: AllCpuTime=100 QualificationTime=2400 CPUSkewPercent=90
        
    GID:  86 Type: EXCEPTION Group: class1:grp1:2
    ABORT: BlockTime=1200 ElapsedTime=2400
    
    ```
    
    上述示例查看到的控制组配置信息如[表1](https://opengauss.org/zh/docs/2.1.0/docs/Developerguide/%E8%AE%BE%E7%BD%AE%E6%8E%A7%E5%88%B6%E7%BB%84.html#zh-cn_topic_0085032167_zh-cn_topic_0059777958_t6ef2f8b1d69342eda1f26e57003015c2)所示。
    
    **表 1** 控制组配置信息
    
    | 
    GID
    
     | 
    
    类型
    
     | 
    
    名称
    
     | 
    
    Percent（%）信息
    
     | 
    
    特定信息
    
     |
    | --- | --- | --- | --- | --- |
    | 
    
    0
    
     | 
    
    Top控制组
    
     | 
    
    Root
    
     | 
    
    1000代表总的系统资源为1000份。
    
    括号中的50代表IO资源的50%。
    
    openGauss不通过控制组对IO资源做控制，因此下面其他控制组信息中仅涉及CPU配额情况。
    
     | 
    
    \-
    
     |
    | 
    
    1
    
     | 
    
    Gaussdb:omm
    
     | 
    
    系统中只运行一套数据库程序，Gaussdb:omm控制组默认配额为833，数据库程序和非数据库程序的比值为（833:167=5:1）。
    
     | 
    
    \-
    
     |
    | 
    
    2
    
     | 
    
    Backend
    
     | 
    
    Backend和Class括号中的40和60，代表Backend占用Gaussdb:dbuser控制组40%的资源，Class占用Gaussdb:dbuser控制组60%的资源。
    
     | 
    
    \-
    
     |
    | 
    
    3
    
     | 
    
    Class
    
     | 
    
    \-
    
     |
    | 
    
    4
    
     | 
    
    Backend控制组
    
     | 
    
    DefaultBackend
    
     | 
    
    括号中的80和20代表DefaultBackend和Vacuum占用Backend控制组80%和20%的资源。
    
     | 
    
    TopGID：代表Top类型控制组中Backend组的GID，即2。
    
     |
    | 
    
    5
    
     | 
    
    Vacuum
    
     |
    | 
    
    20
    
     | 
    
    Class控制组
    
     | 
    
    DefaultClass
    
     | 
    
    DefaultClass和class1的20和40代表占Class控制组20%和40%的资源。因为当前只有两个Class组，所有它们按照20:40的比例分配Class控制组499的系统配额，则分别为166和332。
    
     | 
    
    -   TopGID：代表DefaultClass和class1所属的上层控制（Top控制组中的Class组）的GID，即3。
    -   MaxLevel：Class组当前含有的Workload组的最大层次，DefaultClass没有Workload Cgroup，其数值为1。
    -   RemPCT:代表Class组分配Workload组后剩余的资源百分比。如class1中剩余的百分比为70。
    
     |
    | 
    
    21
    
     | 
    
    class1
    
     |
    | 
    
    86
    
     | 
    
    Workload控制组
    
     | 
    
    grp1:2
    
    （该名称由Workload Cgroup Name和其在class中的层级组成，它是class1的第一个Workload组，层级为2，每个Class组最多10层Workload Cgroup。）
    
     | 
    
    根据设置，其占class1的百分比为30，则为332\*30%=99。
    
     | 
    
    -   ClsGID：代表Workload控制组所属的上层控制组（class1控制组）的GID。
    -   WDLevel：代表当前Workload Cgroup在对应的Class组所在的层次。
    
     |
    | 
    
    724
    
     | 
    
    Timeshare控制组
    
     | 
    
    Low
    
     | 
    
    \-
    
     | 
    
    Rate：代表Timeshare中的分配比例，Low最少为1，Rush最高为8。这四个Timeshare组的资源配比为Rush:High:Medium:Low=8:4:2:1
    
     |
    | 
    
    725
    
     | 
    
    Medium
    
     | 
    
    \-
    
     |
    | 
    
    726
    
     | 
    
    High
    
     | 
    
    \-
    
     |
    | 
    
    727
    
     | 
    
    Rush
    
     | 
    
    \-
    
     |
    
2.  查看操作系统中树形结构的控制组信息。
    
    执行如下命令可以查询控制组树形结构信息。
    
    ```
    复制代码gs_cgroup -P
    
    ```
    
    返回信息如下，其中shares代表操作系统中CPU资源的动态资源配额“cpu.shares”的数值，cpus代表操作系统中CPUSET资源的动态资源限额“cpuset.cpus”的数值，指的是该控制组能够使用的核数范围。
    
    ```
    复制代码Mount Information:
    cpu:/dev/cgroup/cpu
    blkio:/dev/cgroup/blkio
    cpuset:/dev/cgroup/cpuset
    cpuacct:/dev/cgroup/cpuacct
        
    Group Tree Information:
    - Gaussdb:wangrui (shares: 5120, cpus: 0-20, weight: 1000)
            - Backend (shares: 4096, cpus: 0-20, weight: 400)
                    - Vacuum (shares: 2048, cpus: 0-20, weight: 200)
                    - DefaultBackend (shares: 8192, cpus: 0-20, weight: 800)
            - Class (shares: 6144, cpus: 0-20, weight: 600)
                    - class1 (shares: 4096, cpus: 0-20, weight: 400)
                            - RemainWD:1 (shares: 1000, cpus: 0-20, weight: 100)
                                    - RemainWD:2 (shares: 7000, cpus: 0-20, weight: 700)
                                            - Timeshare (shares: 1024, cpus: 0-20, weight: 500)
                                                    - Rush (shares: 8192, cpus: 0-20, weight: 800)
                                                    - High (shares: 4096, cpus: 0-20, weight: 400)
                                                    - Medium (shares: 2048, cpus: 0-20, weight: 200)
                                                    - Low (shares: 1024, cpus: 0-20, weight: 100)
                                    - grp1:2 (shares: 3000, cpus: 0-5, weight: 300)
                            - TopWD:1 (shares: 9000, cpus: 0-20, weight: 900)
                    - DefaultClass (shares: 2048, cpus: 0-20, weight: 200)
                            - RemainWD:1 (shares: 1000, cpus: 0-20, weight: 100)
                                    - Timeshare (shares: 1024, cpus: 0-20, weight: 500)
                                            - Rush (shares: 8192, cpus: 0-20, weight: 800)
                                            - High (shares: 4096, cpus: 0-20, weight: 400)
                                            - Medium (shares: 2048, cpus: 0-20, weight: 200)
                                            - Low (shares: 1024, cpus: 0-20, weight: 100)
                            - TopWD:1 (shares: 9000, cpus: 0-20, weight: 900)
    
    ```
    
3.  通过系统视图获取控制组配置信息。
    
    a.[使用gsql连接](https://opengauss.org/zh/docs/2.1.0/docs/Developerguide/%E4%BD%BF%E7%94%A8gsql%E8%BF%9E%E6%8E%A5.html)数据库。
    

b.获取系统中所有控制组的配置信息。

```
复制代码```
openGauss=# SELECT * FROM gs_all_control_group_info;
```

```

本文档遵循[知识共享许可协议CC 4.0](https://creativecommons.org/licenses/by/4.0/) (http://creativecommons.org/Licenses/by/4.0/)。