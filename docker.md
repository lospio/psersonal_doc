#author/zhangzhilingyun
```shell
docker exec -it spacture_test1_worker2 bash
#docker 本机往容器传递文件
docker cp 本地文件路径 ID全称:容器路径

docker run --cap-add=SYS_PTRACE --cap-add=SYS_ADMIN --security-opt seccomp=unconfined --privileged -d -t -P --name ptrace_test --rm --network host  172.16.1.99/transwarp/spacture:transwarp-8.1.0-rc2

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
```
