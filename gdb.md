#### 使用jvm
```shell
handle SIGSEGV noprint  
handle SIGSEGV nostop  
set print thread-events off
```
#### 批量加断点
1. 每一行 `b func`
2. gdb 里面 `source file`
#### gdb内容打印到日志文件
```bash
# 选定 on -off间内容打印到日志
(gdb) set logging file <file name>
(gdb) set logging on
(gdb) info functions
(gdb) set logging off
```
```bash
# 全部
gdb |tee newfile
```
#### 手动加载动态链接库
```bash
sharedlibrary libtest

# 显示源文件
info source

# 显示加载的lib
info sharedlibrary

```
**参考**
1. [手动添加符号表](https://stackoverflow.com/questions/30281766/need-to-load-debugging-symbols-for-shared-library-in-gdb)
2. [sharedlibrary command](https://visualgdb.com/gdbreference/commands/sharedlibrary)
