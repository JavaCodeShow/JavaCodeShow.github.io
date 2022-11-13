---
author: 江峰
title: "docker启动redis"
date: 2020-05-12 22:15
comments: true
categories: docker
summary: 通过docker启动redis。
tags: 
	- docker

---



# docker启动redis

1. 查询redis镜像

   ```
   docker search redis
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull redis:6.0
   ```

3. 查看redis镜像

   ```
   docker images | grep redis
   ```

4. 创建文件挂载目录

   ```
   mkdir /usr/java/docker/redis
   ```

   将默认的redis.conf配置放到这个目录下面。（该文件可以从网上找一下，下载下来）作为映射文件。注意下载对应版本的redis，解压将配置文件复制出来。

   ```
   http://download.redis.io/releases/
   ```

5. 修改redis.conf配置文件

   ```
   1.bind 127.0.0.1 修改为 bind 0.0.0.0
   127.0.0.1  	表示只允许本地访问,无法远程连接
   0.0.0.0     表示任何ip都可以访问
   
   2.protected-mode yes 改为 protected-mode no
   yes			  保护模式，只允许本地链接
   no			  保护模式关闭
   
   3.daemonize yes 改为 daemonize no
   yes： 代表开启守护进程模式。此时是单进程多线程的模式，redis将在后台运行。
   no： 当前界面将进入redis的命令行界面，exit强制退出或者关闭连接工具都会导致redis进程退出
   
   4.appendonly no 改为 appendonly yes
   yes			  打开持久化
   no			  关闭持久化
   
   5.tcp-keepalive 300 #防止出现远程主机强迫关闭了一个现有的连接的错误 默认是300
   ```

6. 修改配置权限：

   ```
   cd /usr/java/docker/redis
   chmod 777 redis.conf
   ```

7. 使用docker运行redis

   ```
   docker run -p 6379:6379 --name redis \
   -v /usr/java/docker/redis/redis.conf:/etc/redis/redis.conf \
   -v /usr/java/docker/redis/data:/data \
   -d redis:6.0 redis-server /etc/redis/redis.conf \
   --appendonly yes
   ```

   命令解释说明：

   >-p 6379:6379 端口映射：前表示主机部分，：后表示容器部分。
   >
   >--name redis指定该容器名称，查看和进行操作都比较方便。
   >
   >-v 挂载目录，规则与端口映射相同。
   >
   >为什么需要挂载目录：个人认为docker是个沙箱隔离级别的容器，这个是它的特点及安全机制，不能随便访问外部（主机）资源目录，所以需要这个挂载目录机制。
   >
   >-d redis:6.0 表示后台启动redis
   >
   >redis-server /etc/redis/redis.conf  以配置文件启动redis，加载容器内的conf文件，最终找到的是挂载的目录/usr/local/docker/redis/redis.conf
   >
   >–appendonly yes：redis启动后数据持久化

8. 查看是否运行成功

   ```
   docker ps | grep redis
   ```

9. 问题记录：

   解决WARNING overcommit_memory is set to 0 Background save may fail under low memory condition：https://blog.csdn.net/ET1131429439/article/details/126660323







