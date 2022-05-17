### 前置
- java 8及以上版本
- postgresql对应版本的jdbc，配置环境变量，路径放入CLASSPATH
### 安装
```shell
wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.4.3.zip
unzip apache-jmeter-5.4.3
cd apache-jmeter-5.4.3/
#将jmeter的bin目录添加进PATH
vim /etc/profile
export PATH=/share/apache-jmeter-5.4.3/bin:$JAVA_HOME/bin:${PATH}
source /etc/profile
```
### 使用
```shell
#唤出ui
jmeter
# 切换成中文界面Options–Choose Language–Chinese(Simplofied)：
```
### 参考文档
[文档](https://www.cnblogs.com/yimai-series/p/13695228.html)