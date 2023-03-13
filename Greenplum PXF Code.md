---
ctime: 2023-02-07 17:22
tags:
  - simlpe-card
author: lche
alias: null
date updated: 2023-02-14 16:34
---
#Greenplum #vault-squirreldoc 

## PXF in GP

- src
  - extaccess.c
  - gpdb/src/backend/access/external/*
    - url.c
    - url_curl.c
- external scan
  - [[Greenplum external scan readme]]
- 核心流程
  - 从GP执行计划开始
  - 从PXF  connector开始

## PXF server
#### Rest API
- server/pxf-service/src/main/java/org/greenplum/pxf/service/rest/PxfBaseResource.java
- PxfReadResource::read
	- PxfBaseResource::processRequest
		- HttpRequestParser::parseRequest

##### HttpRequestParser::parseRequest
- 解析http request
- 加载profileplugin

```java
HttpRequestParser::parseRequest{

        // first of all, set profile and enrich parameters with information from specified profile
        String profileUserValue = params.removeUserProperty("PROFILE");
        String profile = profileUserValue == null ? null : profileUserValue.toLowerCase();
        context.setProfile(profile);
        addProfilePlugins(profile, params);
}
```

- Bridge call
` pxf/server/pxf-service/src/main/java/org/greenplum/pxf/service/bridge/BaseBridge.java  `

- Read service
`server/pxf-service/src/main/java/org/greenplum/pxf/service/controller/ReadServiceImpl.java`



#### Profile
  - server/pxf-service/src/main/java/org/greenplum/pxf/service/profile/ProfilesConf.java
  - 从配置文件加载定义
    - pxf-profiles.xml
    - pxf-profiles-default.xml

![[pxf-profiles.xml]]
![[pxf-profiles-default.xml]]

- API Examples
	- server/pxf-api/src/main/java/org/greenplum/pxf/api/examples

## 代码统计
count workspace : /Users/lche/Documents/repo/pxf
- total files : 3012
- total code lines : 713656
- total comment lines : 35242
- total blank lines : 37885
| extension   | total code | total comment | total blank | percent |
| ----------- | ---------- | ------------- | ----------- | ------- |
| .spec       | 39         | 3             | 12          | 0.0055  |
|             | 2482       | 491           | 502         | 0.35    |
| .md         | 2288       | 508           | 910         | 0.32    |
| .sql        | 1870       | 1786          | 1031        | 0.26    |
| .bash       | 2397       | 1388          | 528         | 0.34    |
| .rb         | 22         | 0             | 4           | 0.0031  |
| .out        | 3472       | 107           | 82          | 0.49    |
| .c          | 10435      | 2666          | 2426        | 1.5     |
| .h          | 439        | 514           | 167         | 0.062   |
| .control    | 13         | 0             | 0           | 0.0018  |
| .java       | 55846      | 17665         | 13440       | 7.8     |
| .properties | 533        | 14            | 89          | 0.075   |
| .xml        | 4679       | 498           | 789         | 0.66    |
| .py         | 41163      | 6456          | 12062       | 5.8     |
| .Readme     | 87         | 0             | 15          | 0.012   |
| .txt        | 674        | 0             | 5           | 0.094   |
| .hql        | 447        | 0             | 62          | 0.063   |
| .conf       | 1531       | 0             | 328         | 0.21    |
| .sh         | 1714       | 624           | 508         | 0.24    |
| .csv        | 542603     | 0             | 0           | 76      |
| .cfg        | 116        | 4             | 33          | 0.016   |
| .avsc       | 1085       | 0             | 0           | 0.15    |
| .json       | 3947       | 0             | 90          | 0.55    |
| .yml        | 4439       | 1473          | 341         | 0.62    |
| .dat        | 100        | 0             | 0           | 0.014   |
| .ini        | 9          | 0             | 0           | 0.0013  |
| .template   | 21         | 0             | 0           | 0.0029  |
| .ans        | 19772      | 113           | 741         | 2.8     |
| .config     | 15         | 0             | 5           | 0.0021  |
| .pl         | 2071       | 360           | 654         | 0.29    |
| .version    | 1          | 0             | 0           | 0.00014 |
| .gradle     | 421        | 181           | 148         | 0.059   |
| .scss       | 16         | 1             | 5           | 0.0022  |
| .js         | 656        | 75            | 126         | 0.092   |
| .erb        | 5602       | 272           | 2436        | 0.78    |
| .lock       | 204        | 1             | 3           | 0.029   |
| .schema     | 16         | 0             | 0           | 0.0022  |
| .bat        | 44         | 0             | 10          | 0.0062  |
| .bin        | 1          | 0             | 0           | 0.00014 |
| .state      | 393        | 6             | 84          | 0.055   |
| .yaml       | 402        | 0             | 49          | 0.056   |
| .sum        | 203        | 1             | 0           | 0.028   |
| .go         | 1360       | 25            | 196         | 0.19    |
| .mod        | 20         | 10            | 3           | 0.0028  |
| .mk         | 8          | 0             | 1           | 0.0011  |


## 参考

- <https://github.com/greenplum-db/pxf>
- [[如何编译PXF]]
