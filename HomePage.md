---
ctime: 2023-03-09 17:51
tags: index-page, vault-squirreldoc 
author: zhangzhilingyun
alias: 
---
## 项目
## 工作日志
```dataview
table file.mday as 更新时间 from #log where author = "zhangzhilingyun" sort file.mtime desc
```
## 技术专题
```dataview
list  from #tech-column  where author = "zhangzhilingyun" sort file.mtime desc
```

## 方案
```dataview
list  from #方案  where author = "zhangzhilingyun" sort file.mtime desc
```
## 技术
```dataview
list  from #tech  where author = "zhangzhilingyun" sort file.mtime desc
```
## 更新
```dataview
table file.mday as 更新时间 from "/" where author = "zhangzhilingyun" sort file.mtime desc
```
## 热点图
```ActivityHistory
/
```
