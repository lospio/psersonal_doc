---
ctime: <% tp.file.creation_date () %>
tags: simlpe-card
author: zhilingyun.zhang 
alias: 
---
#log 
# 编译
```bash
go env -w GOPROXY=https://goproxy.cn
chmod +x server/gradlew
make cli server 
make install
```