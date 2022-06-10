---
author: 江峰
title: "java应用服务器内存处理"
date: 2020-05-11 22:15
comments: true
categories: linux
summary: 处理服务器内存问题。
tags: 
	- 处理服务器内存问题
---

# java服务器内存处理

## 查看服务器总内存占用

```
free -h
```

显示如下：

```
[root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# free -h
              total        used        free      shared  buff/cache   available
Mem:           1.8G        1.4G        170M        3.7M        259M        284M
Swap:            0B          0B          0B
[root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# 

```

## 清除操作系统缓存

```
echo 3 > /proc/sys/vm/drop_caches
```



## 查看java内存占用

```
top -o %MEM -b -n 1 | grep java | awk '{print "PID: "$1" \t 虚拟内存: "$5 / 1024"M \t 物理内存: "$6 / 1024"M \t 共享内存: "$7 / 1024"M \t CPU使用率: "$9"% \t 内存使用率: "$10"%"}'
```

显示如下：

```
[root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# top -o %MEM -b -n 1 | grep java | awk '{print "PID: "$1" \t 虚拟内存: "$5 / 1024"M \t 物理内存: "$6 / 1024"M \t 共享内存: "$7 / 1024"M \t CPU使用率: "$9"% \t 内存使用率: "$10"%"}'
PID: 12959       虚拟内存: 2123.05M      物理内存: 329.488M      共享内存: 7.28125M      CPU使用率: 0.0%         内存使用率: 17.9%
PID: 10799       虚拟内存: 2110.75M      物理内存: 194.641M      共享内存: 13.418M       CPU使用率: 0.0%         内存使用率: 10.6%
PID: 28249       虚拟内存: 2508.25M      物理内存: 194.316M      共享内存: 6.32031M      CPU使用率: 0.0%         内存使用率: 10.6%
PID: 25613       虚拟内存: 2331.65M      物理内存: 169.684M      共享内存: 5.15625M      CPU使用率: 0.0%         内存使用率: 9.2%
[root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# 
```

## 查看PID所在目录

```
lsof -p PID
# 示例如下
# cwd: 表示 current work dirctory, 即：应用程序的当前工作目录
lsof -p PID | grep cwd
```



## 指定JVM内存运行java包

```
nohup java -jar -Xms64M -Xmx64M -XX:PermSize=64M -XX:MaxPermSize=64M microservicecloud-eureka-server-7001-1.0-SNAPSHOT.jar  >/dev/null &

```

>  Xms : 堆内存初始大小
>
>  Xmx : 堆内存最大值 PermSize : 
>
> 永久内存初始大小 MaxPermSize ：
>
>  永久内存最大值 

