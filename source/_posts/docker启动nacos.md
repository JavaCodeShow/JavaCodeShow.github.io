---
author: 江峰
title: "docker启动nacos"
date: 2020-05-12 22:15
comments: true
categories: docker
summary: 通过docker启动nacos。
tags: 
	- docker

---



# docker启动nacos



## 单机模式

1. 查询nacos镜像

   ```
   docker search nacos
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull nacos/nacos-server
   ```

3. 查看nacos镜像

   ```
   docker images  | grep nacos
   ```

4. 使用docker运行nacos

   ```
   docker run -d -p 8848:8848 --env MODE=standalone  -e JVM_XMS=128m -e JVM_XMX=128m  --name nacos   nacos/nacos-server
   ```

   命令解释说明：

   -p 8848:8848 端口映射：前表示主机部分，：后表示容器部分。

   --name nacos 指定该容器名称，查看和进行操作都比较方便。

   -e JVM_XMS=128m -e JVM_XMX=128m  给nacos分配jvm的内存。内存够的话可以不加这一行

   --env MODE=standalone  单机模式启动

5. 查看是否运行成功

   ```
   docker ps | grep nacos
   ```

   



