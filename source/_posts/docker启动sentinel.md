---
author: 江峰
title: "docker启动sentinel"
date: 2024-04-25 16:15
comments: true
categories: docker
summary: 通过docker启动sentinel
tags: 
	- docker

---

<meta name="referrer" content="no-referrer" />

# docker启动sentinel

1. 查询sentinel镜像

   ```
   docker search bladex/sentinel-dashboard
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull bladex/sentinel-dashboard
   ```

3. 查看sentinel镜像

   ```
   docker images | grep sentinel
   ```

4. 启动sentinel

   ```
   docker run -d --name sentinel -p 8858:8858 bladex/sentinel-dashboard
   ```

8. 查看是否运行成功

   ```
   docker ps | grep sentinel
   ```

9. 查看启动日志

   ```
   docker logs sentinel
   ```

10. 在浏览器地址栏访问 http://ip:8858 ，进入到sentinel的控制台

   