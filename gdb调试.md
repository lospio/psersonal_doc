1 psql -U postgres -h shiva04 -p 5432 -d ads
2 ps -efw找到pid
3 gdb attach $pid
4 执行sql
5 gdb上出现segment fault 
6 gdb$ bt