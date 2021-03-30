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
   docker pull redis
   ```

3. 查看redis镜像

   ```
   docker image  | grep redis
   ```

4. 创建文件挂载目录

   1. mkdir /usr/java/docker/redis 
   2. 将默认的redis.conf配置放到这个目录下面。（该文件从网上找一下，下载下来）作为映射文件。

5. 使用docker运行redis

   ```
   docker run -p 6379:6379 --name redis-6379 -v /usr/java/docker/redis/redis.conf:/etc/redis/redis.conf -v /usr/java/docker/redis/data:/data -d redis redis-server /etc/redis/redis.conf --appendonly yes
   ```

   命令解释说明：

   -p 6379:6379 端口映射：前表示主机部分，：后表示容器部分。

   --name redis-6379  指定该容器名称，查看和进行操作都比较方便。

   -v 挂载目录，规则与端口映射相同。

   为什么需要挂载目录：个人认为docker是个沙箱隔离级别的容器，这个是它的特点及安全机制，不能随便访问外部（主机）资源目录，所以需要这个挂载目录机制。

   -d redis 表示后台启动redis

   redis-server /etc/redis/redis.conf  以配置文件启动redis，加载容器内的conf文件，最终找到的是挂载的目录/usr/local/docker/redis/redis.conf

6. 查看是否运行成功

   ```
   docker ps | grep redis
   ```

   








