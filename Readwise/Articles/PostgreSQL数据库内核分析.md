---
March 20, 2023
---
# PostgreSQL数据库内核分析

![rw-book-cover](https://readwise-assets.s3.amazonaws.com/static/images/article2.74d541386bbf.png)

## Metadata
- Author: [[彭智勇，彭煜玮编著]]
- Full Title: PostgreSQL数据库内核分析
- Category: #articles
- URL: https://readwise.io/reader/document_raw_content/41297447

## Highlights
- 连接管理系统(系统控制器) ([View Highlight](https://read.readwise.io/read/01gvydndjzh8ch139yahzczkp0))
- 编译执行系统 ([View Highlight](https://read.readwise.io/read/01gvydnf6bnmb4nvhyv0xjnjfq))
- 存储管理系统 ([View Highlight](https://read.readwise.io/read/01gvydnhwrpp96n5qkke0vhg2x))
- 事务
  系统 ([View Highlight](https://read.readwise.io/read/01gvydnm1zsmb5yc8jyj95r04p))
- 系统表 ([View Highlight](https://read.readwise.io/read/01gvydnr7qzz9vkg6e1tmvyeem))
- 。连接管理系统接受外部操作对系统
  的请求，对操作请求进行预处理和分发，起系统逻辑控制作用;编译执行系统由查询编译器、查询
  执行器组成，完成操作请求在数据库中的分析处理和转化工作，最终实现物理存储介质中数据的操
  作:存储管理系统由索引管理器、内存管理器、外存管理器组成，负责存储和管理物理数据，提供 ([View Highlight](https://read.readwise.io/read/01gvydq1bvms3fh59bw8j8mvtf))
- l 仰.ql
  1 1 应用程序 l 其他请求 |
  '
  '连接管理系统才系统撞倒器 卡~~-
  ; 二2222?口- -.:-.;;-.;;-.;;-• .;;-~一-Z气i---- …·
  而正在日| 查询编译器卡?
  : 编得执行持斗 查询;行器，!
  ，二工乙:JL工工工士.…..，r_ =-._…
  !
  r 刺l管理豁‘
  事务系统
  :
  L
  fî:lìUt
  J L
  1'lfiftilt
  J
  图 2 - 1 PostgreSQL 体系结构 ([View Highlight](https://read.readwise.io/read/01gvydp7sd59x998j2dy4f2f19))
- 对编译查询系统的支持;事务系统囱事务管理器、日志管理器、并发控制、锁管理器组成，日志管
  理器和事务管理器完成对操作请求处理的事务一致性支持，锁管理器和并发控制提供对并发访问数
  据的一致性支持E 系统表是 PostgreSQL数据库的元信息管理中心，包括数据库对象信息和数据库管
  理控制信息。 系统表管理元数据信息，将 PostgreSQL数据库的各个模块有机地连接在一起，形成一
  个高效的数据管理系统。 ([View Highlight](https://read.readwise.io/read/01gvydq6159e3grrzr1pe2j4d6))
- 。数据字典 ([View Highlight](https://read.readwise.io/read/01gvydrkzxzhedbf0s9cff1k8r))
- 种对象的描述信息 ([View Highlight](https://read.readwise.io/read/01gvydrq5s1czha16cy1n1550p))
- 各种对象的细节信息 ([View Highlight](https://read.readwise.io/read/01gvydrtv55rv9y8b4rh0a1jjm))
- 所有对象及其属性 ([View Highlight](https://read.readwise.io/read/01gvyds5y91hsn57a6ckqha8g6))
- 的描述信息 ([View Highlight](https://read.readwise.io/read/01gvyds7hsbypy8390f952wxt4))
- 对象之间关系的描述信息 ([View Highlight](https://read.readwise.io/read/01gvydsaaxccd912ede0eskqbz))
- 、对象属性的自然语言含义
  以及数据字典变化的历史(即数据库的状态信息) ([View Highlight](https://read.readwise.io/read/01gvydsdpzvaxyy758gqtwed9h))
- 。数据字典 ([View Highlight](https://read.readwise.io/read/01gvydth5efftkt5s00xv99jwm))
- 是关系数据库系统管理控制信息的核
  心， ([View Highlight](https://read.readwise.io/read/01gvydwyz3vzdew8n43psqs29v))
- 系统表扮演着数据字典的角色。 ([View Highlight](https://read.readwise.io/read/01gvydx18ax16bpr00fr7jefaf))
