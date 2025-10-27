#author/zhangzhilingyun
```shell
docker exec -it spacture_test1_worker2 bash
#docker 本机往容器传递文件
docker cp 本地文件路径 ID全称:容器路径

docker run --cap-add=SYS_PTRACE --cap-add=SYS_ADMIN --security-opt seccomp=unconfined --privileged=true -d -it -P --name ptrace_test --rm --network host --ulimit core=-1 172.16.1.99/spatial/perf/postgresql:spacture-1.1.0-10.15 bash(/usr/sbin/init)

docker run -it -d --cap-add=SYS_PTRACE --cap-add=SYS_ADMIN --security-opt seccomp=unconfined --privileged=true -v /sys/kernel/debug:/sys/kernel/debug:rw  -v /lib/modules:/lib/modules:ro  -v /usr/src:/usr/src:ro  -v /etc/localtime:/etc/localtime:ro --name=bcc  --pid=host --network host bcc:v1 bash

	 

docker exec -it -e COLUMNS=$(tput cols) -e LINES=$(tput lines) ptrace_test bash
```

```bash
docker run --network host -it -d \
	--name arm_compile \
    -v /tmp/pg-build:/tmp/pg-build \
    -v $(pwd):/opt/transwarp/spatial/build/postgresql \
    -v $(pwd)/ci-transwarp/dist:/usr/lib/spatial/postgresql-10 \
    172.16.1.99/spatial/arm64v8/build/postgresql:spacture-REL_10_TRANSWARP_STABLE-centos7\
    shell
exi```

## 容器中生成core文件
[允许在docker中生成core文件](https://tinylab.org/coredump-in-docker/)
`echo "/tmp/cores/core.%e.%p" > /proc/sys/kernel/core_pattern`

# 自定义网络
```bash
docker network create --driver bridge --subnet 172.168.1.0/24 --gateway 172.168.0.1 mynet
iptables -t nat -A POSTROUTING -s 172.168.0.0 -j SNAT --to 172.18.120.27
```
-   `-t`: 类型为nat
-   `-A`: 添加新规则到规则链的末尾
-   `POSTROUTING`: 在包就要离开防火墙之前改变其源地址
-   `-s`: 源地址段，这里设置我的内网地址网段10.0.0.0/24
-   `-j SNAT`: 满足snat条件的时候跳转
-   `--to`: 跳转时设置的Ip地址
-   `-o`: 跳转时的出口设备为eth0