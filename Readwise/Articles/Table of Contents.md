---
April 11, 2023
---
# Table of Contents

![rw-book-cover](https://readwise-assets.s3.amazonaws.com/static/images/article2.74d541386bbf.png)

## Metadata
- Author: [[Unknown]]
- Full Title: Table of Contents
- Category: #articles
- URL: https://readwise.io/reader/document_raw_content/24882423

## Highlights
- 随机访问 ([View Highlight](https://read.readwise.io/read/01gxmnp12rv91az0f47a9gq264))
- 相对节约存储空间 ([View Highlight](https://read.readwise.io/read/01gxmnp88chnh8rcbn0hqrj5g6))
- ⼀次性分配够 ([View Highlight](https://read.readwise.io/read/01gxmnpbs4fw0w0nkmcvt0yczq))
- 扩容 ([View Highlight](https://read.readwise.io/read/01gxmnpf181rhhnwr9de2t8f0d))
- 插⼊和删除 ([View Highlight](https://read.readwise.io/read/01gxmnpnqa86x16nz7zad2ye83))
- 不能随机访问 ([View Highlight](https://read.readwise.io/read/01gxmntayjx3sebgpf1523q361))
- 消耗相对更多的储存空间 ([View Highlight](https://read.readwise.io/read/01gxmntkc8akzvf04amztrnp7q))
- 「重叠⼦问题」 ([View Highlight](https://read.readwise.io/read/01gxq29mdfwth63z0k2jqs2bxq))
- 「最优⼦结构」 ([View Highlight](https://read.readwise.io/read/01gxq29pvwjt30ahh0vm0snt4j))
- 重叠⼦问题、最优⼦结构、状态转移⽅程就是动态规划三要素。 ([View Highlight](https://read.readwise.io/read/01gxq2ahwvmv8ppmwckn1t3gec))
- 明确「状态」 -> 定义 dp 数组/函数的含义 -> 明确「选择」-> 明确 base
  case。 ([View Highlight](https://read.readwise.io/read/01gxq2b8en1g81w53rfx9yzhhk))
- 这就是动态规划问题的第⼀个性质：重叠⼦问题。下⾯，我们想办法解决这
  个问题。 ([View Highlight](https://read.readwise.io/read/01gxq2k227erag4wdeamcvdnvh))
- 实际上，带「备忘录」的递归算法，把⼀棵存在巨量冗余的递归树通过「剪
  枝」，改造成了⼀幅不存在冗余的递归图，极⼤减少了⼦问题（即递归图中
  节点）的个数。 ([View Highlight](https://read.readwise.io/read/01gxq2mfmshyhs4hf75ha2044k))
- 所以，本算法的时间复杂度是 O(n)。⽐起暴⼒算法，是降维打击。 ([View Highlight](https://read.readwise.io/read/01gxq2nj2ppxwfz8n9hj259698))
- 只不过这种⽅法叫做「⾃顶
  向下」，动态规划叫做「⾃底向上」。 ([View Highlight](https://read.readwise.io/read/01gxq2pdxay0gnz5ec9yxtgb9h))
- 。实际上，带备忘录的递归解法中的「备忘
  录」，最终完成后就是这个 DP table，所以说这两种解法其实是差不多的，
  ⼤部分情况下，效率也基本相同。 ([View Highlight](https://read.readwise.io/read/01gxq2qw55ccfdnagpet4bjbxg))
- ⽐如说，你的原问题是考出最⾼的总成绩，那么你的⼦问题就是要把语⽂考
  到最⾼，数学考到最⾼…… 为了每门课考到最⾼，你要把每门课相应的选
  择题分数拿到最⾼，填空题分数拿到最⾼…… 当然，最终就是你每门课都
  是满分，这就是最⾼的总成绩。
  得到了正确的结果：最⾼的总成绩就是总分。因为这个过程符合最优⼦结
  构，“每门科⽬考到最⾼”这些⼦问题是互相独⽴，互不⼲扰的。 ([View Highlight](https://read.readwise.io/read/01gxq2vaz4e70htejraba3d1ts))
- 回到凑零钱问题，为什么说它符合最优⼦结构呢？⽐如你想求 amount =
  11 时的最少硬币数（原问题），如果你知道凑出 amount = 10 的最少硬币
  数（⼦问题），你只需要把⼦问题的答案加⼀（再选⼀枚⾯值为 1 的硬币）
  就是原问题的答案，因为硬币的数量是没有限制的，⼦问题之间没有相互
  制，是互相独⽴的。 ([View Highlight](https://read.readwise.io/read/01gxq2vwm69yra6hhvm1ndrd0c))
- res = float('INF') ([View Highlight](https://read.readwise.io/read/01gxq2x5ah8ekkf8k0typ43nad))
- 1、路径：也就是已经做出的选择。
  2、选择列表：也就是你当前可以做的选择。
  3、结束条件：也就是到达决策树底层，⽆法再做选择的条件。 ([View Highlight](https://read.readwise.io/read/01gxq375pdrwkdfk4m2tyba1dm))
- 其核⼼就是 for 循环⾥⾯的递归，在递归调⽤之前「做选择」，在递归调⽤
  之后「撤销选择」，特别简单。 ([View Highlight](https://read.readwise.io/read/01gxq380bfjh95vxz34eqtwevf))
- 只要从根遍历这棵树，记录路径上的数字，其实就是所有的全排列。我们不
  妨把这棵树称为回溯算法的「决策树」。 ([View Highlight](https://read.readwise.io/read/01gxq38tjb5ymm08mx7zvk7q9z))
- ⽐如说这个问题，每天都有三种「选择」：买⼊、卖出、⽆操作，我们⽤
  buy, sell, rest 表⽰这三种选择。但问题是，并不是每天都可以任意选择这三
  种选择的，因为 sell 必须在 buy 之后，buy 必须在 sell 之后。那么 rest 操作
  还应该分两种状态，⼀种是 buy 之后的 rest（持有了股票），⼀种是 sell 之
  后的 rest（没有持有股票）。⽽且别忘了，我们还有交易次数 k 的限制，就
  是说你 buy 还只能在 k > 0 的前提下操作。
  很复杂对吧，不要怕，我们现在的⽬的只是穷举，你有再多的状态，⽼夫要
  做的就是⼀把梭全部列举出来。这个问题的「状态」有三个，第⼀个是天
  数，第⼆个是允许交易的最⼤次数，第三个是当前的持有状态（即之前说的
  rest 的状态，我们不妨⽤ 1 表⽰持有，0 表⽰没有持有）。然后我们⽤⼀个
  三维数组就可以装下这⼏种状态的全部组合： ([View Highlight](https://read.readwise.io/read/01gxq3rkvcd4a3sbsvgmra0a5e))
- dp[i][k][0 or 1]
  0 <= i <= n-1, 1 <= k <= K
  n 为天数，⼤ K 为最多交易数
  此问题共 n × K × 2 种状态，全部穷举就能搞定。
  for 0 <= i < n:
  86 ([View Highlight](https://read.readwise.io/read/01gxq3rnny97v7a3at45t50czv))
- for 1 <= k <= K:
  for s in {0, 1}:
  dp[i][k][s] = max(buy, sell, rest)
  ⽽且我们可以⽤⾃然语⾔描述出每⼀个状态的含义，⽐如说 dp[3][2][1]
  的含义就是：今天是第三天，我现在⼿上持有着股票，⾄今最多进⾏ 2 次交
  易。再⽐如 dp[2][3][0] 的含义：今天是第⼆天，我现在⼿上没有持有股
  票，⾄今最多进⾏ 3 次交易。很容易理解，对吧？
  我们想求的最终答案是 dp[n - 1][K][0]，即最后⼀天，最多允许 K 次交易，
  最多获得多少利润。读者可能问为什么不是 dp[n - 1][K][1]？因为 [1] 代表⼿
  上还持有股票，[0] 表⽰⼿上的股票已经卖出去了，很显然后者得到的利润
  ⼀定⼤于前者。 ([View Highlight](https://read.readwise.io/read/01gxq3rt29yhnznzhf7t7yj35c))
