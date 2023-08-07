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
   docker pull redis:5.0
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

   1. bind：默认情况bind=127.0.0.1，只能接受本机的访问请求，不写的情况下，无限制接受任何ip地址的访问，为了能够让除本机的其余服务器也能远程访问，将 bind 127.0.0.1 -::1注释掉

      ```
      #bind 127.0.0.1
      ```

   2. protected-mode：为了能够让除本机的其余服务器也能远程访问，将 protected-mode yes 修改为 protected-mode no

      ```
      protected-mode no
      ```

   3. daemonize：是否为后台进程，设置为no，守护进程，后台启动（docker里面需要设置为no）

      ```
      daemonize no
      ```

   4. appendonly：是否开启aof持久化，设置为yes

      ```
      appendonly yes
      ```

6. 使用docker运行redis

   ```
   docker run -p 6379:6379 --name redis \
   -v /usr/java/docker/redis/redis.conf:/etc/redis/redis.conf \
   -v /usr/java/docker/redis/data:/data \
   -d redis:5.0 redis-server /etc/redis/redis.conf
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
   
7. 查看是否运行成功

   ```
   docker ps | grep redis
   ```

8. 问题记录：

   解决WARNING overcommit_memory is set to 0 Background save may fail under low memory condition：https://blog.csdn.net/ET1131429439/article/details/126660323
   
   redis客户端链接失败：https://blog.csdn.net/m0_67394006/article/details/126495657
   
   解决redis启动时的三个警告：https://blog.csdn.net/a13568hki/article/details/107038136



