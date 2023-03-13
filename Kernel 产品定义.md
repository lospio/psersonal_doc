---
ctime: 2023-02-27 16:28
tags: simlpe-card
author: lche
alias: 
---
#vault-squirreldoc 

## Spacture Kernel/Distributed PostgreSQL Kernel/Kernel
#### 产品体系结构
![[Kernel 产品定义 2023-02-27.excalidraw]]
- 3层
	- L1（database kernel）
	- L2（basic component）
	- L3 （toolkits）
- 如何打包？
	- L1 + L2 是构成产品的最小化单位，一起打包。
	- L3是辅助工具，独立管理。

- 如何定义配套关系？
	![[Drawing 2023-02-27.excalidraw]]
	- 以PostgreSQL的版本为主， Citus和patroni的版本为辅
	- 一个思路
		- 制作一个docker镜像包含多个版本的软件，在初始化docker时，用脚本
