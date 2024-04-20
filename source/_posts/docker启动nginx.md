---
author: 江峰
title: "docker启动nginx"
date: 2024-05-12 22:00
comments: true
categories: docker
summary: 通过docker启动nginx。
tags: 
	- docker

---

<meta name="referrer" content="no-referrer" />

# docker启动nginx

1. 从docker hub拉取镜像

   ```
   docker pull nginx:1.25
   ```

2. 查看nginx镜像

   ```
   docker images | grep nginx
   ```

3. 创建挂载目录

   ```
   mkdir -p /usr/java/docker/nginx/html && mkdir -p /usr/java/docker/nginx/conf
   ```

4. 临时启动nginx

   ```
   docker run --name nginx -p 80:80 -d nginx:1.25
   ```

5. 复制配置文件

   ```
   docker cp nginx:/usr/share/nginx/html /usr/java/docker/nginx
   
   docker cp nginx:/etc/nginx/conf.d/default.conf /usr/java/docker/nginx/conf
   
   docker cp nginx:/etc/nginx/nginx.conf /usr/java/docker/nginx/conf
   ```

6. 删除nginx

   ```
   docker rm -f nginx
   ```

7. 挂载文件启动nginx

   ```
   docker run --name nginx -p 80:80 -p 443:443 \
   -v /usr/java/docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
   -v /usr/java/docker/nginx/html:/usr/share/nginx/html \
   -d nginx:1.25
   ```

8. 查看是否运行成功

   ```
   docker ps | grep nginx
   ```
