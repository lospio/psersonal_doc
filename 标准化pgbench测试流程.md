## pgbench最佳实践
1. scale factor 至少要大于 client
2. 至少做三次取平均值
3. write-heavy tests需要长时间，十分钟左右
4. autovacuum保持一致
5. debug_assertions 为true将极大地影响性能，随着shared_memory上升断言的开销也将增大
6. worker threads必须是cleint的整数倍
7. client不能超过系统核心数量太多
8. 根据disk情况找到client和每次插入数据长度的饱和点（越过之后，效率下降）
##  pgbench测试流程
1. 运行explain (analyze, buffers, verbose) 获取查询计划
2. 获取结果集数量
3. 将结果集导入一个文件，查看结果集大小
4. 设置执行的并发数量，运行脚本
```bash
#!/bin/bash

do_pgbench_for_dir(){

<<PARAM

    $1: 输出文件名称

    $2: 测试文件列表 需要重写const_dir 命令，筛选文件

PARAM

    local output=$1

    shift

    local dir=$@

    arr=(1 5 10 24 50 100)

    echo "开始测试:"

    echo  "     测试文件:$dir"

    echo  "     输出文件:$output"

    echo  "     并发数:${arr[*]}"

    echo  -e "\n"

  

    for file in $dir

    do

        echo "当前测试文件:$file"

        if [ -e $file ]  

        then

            for t in ${arr[*]}

            do

                echo "pgbench -c $t -j $t -n -T 300 -f $file >> $output "

                pgbench -c $t -j $t -n -T 300 -f $file >> $output

            done

        else

            echo "$file is not exist"  

        fi

    done

    echo -e "当前测试完成\n\n\n"

}

  

# const表sql文件命名为const*.sql

# dist表sql文件命名为dist*.sql

const_dir=`ls |grep "const*" |grep -v result`

dist_dir=`ls |grep "dist*" |grep -v result`

const_output='const_result'

dist_output='dist_result'

  

do_pgbench_for_dir $const_output $const_dir

do_pgbench_for_dir $dist_output $dist_dir
```
## pgbench 参数
- `-n`  Perform no vacuuming before running the test. This option is _necessary_ if you are running a custom test scenario that does not include the standard tables `pgbench_accounts`, `pgbench_branches`, `pgbench_history`, and `pgbench_tellers`.
- `-c`  `clients` Number of clients simulated, that is, **number of concurrent database session**s. Default is 1.
- `-C`  Establish a new connection for each transaction, rather than doing it just once per client session. This is useful to measure the connection overhead.
- -f
- -j Number of worker threads within pgbench. Using more than one thread can be helpful on multi-CPU machines. Clients are distributed as evenly as possible among available threads. Default is 1.
- `-P` _`sec`_  Show progress report every _`sec`_ seconds. The report includes the time since the beginning of the run, the tps since the last report, and the transaction latency average and standard deviation since the last report. Under throttling (`-R`), the latency is computed with respect to the transaction scheduled start time, not the actual transaction beginning time, thus it also includes the average schedule lag time.
- `-T`  `seconds `  Run the test for this many seconds, rather than a fixed number of transactions per client. `-t` and `-T` are mutually exclusive.
