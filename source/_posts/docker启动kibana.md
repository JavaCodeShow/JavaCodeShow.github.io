---
author: 江峰
title: "docker启动kibana"
date: 2022-08-03 22:15
comments: true
categories: docker
summary: 通过docker启动kibana
tags: 
	- docker

---

<meta name="referrer" content="no-referrer" />

# docker启动kibana

1. 查询kibana镜像

   ```
   docker search kibana
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull kibana:7.6.0
   ```

3. 查看kibana镜像

   ```
   docker images | grep kibana
   ```

4. 启动kibana

   ```
   docker run -d --name kibana -p 5601:5601 kibana:7.6.0
   ```

5. 配置文件

   在/usr/java/docker文件夹下创建kibana的config文件夹，将docker中kibana的配置挂载在外部，当我们在linux虚拟机中修改kibana的配置文件时，就会同时修改docker中的kibana的配置

   ```
   mkdir -p /usr/java/docker/kibana/config
   ```

   复制配置文件

   ```
   docker cp kibana:/usr/share/kibana/config /usr/java/docker/kibana/
   ```

   移除容器

   ```
   docker rm -f kibana
   ```

   修改配置文件

   ```
   vim /usr/java/docker/kibana/config/kibana.yml
   ```

   ```
   # 服务名字
   server.name: kibana
   # 默认端口
   server.port: 5601
   # 远程访问
   server.host: "0.0.0.0"		
   # ES 服务器的地址(公网ip)
   elasticsearch.hosts: ["http://172.31.128.22:9200"]
   # 索引名
   kibana.index: ".kibana"
   # 支持中文
   i18n.locale: "zh-CN"
   # 监控
   xpack.monitoring.ui.container.elasticsearch.enabled: true
   ```

   查看配置文件

   ```
   cat /usr/java/docker/kibana/config/kibana.yml
   ```

   保证权限问题

   ```
   chmod -R 777 /usr/java/docker
   ```

6. 使用docker运行kibana

   ```
   docker run -d --name kibana \
   -p 5601:5601 \
   -v /usr/java/docker/kibana/config:/usr/share/kibana/config \
   -m 512m \
   -d kibana:7.6.0
   ```

   > 命令解释说明：
   >
   > docker run --name kibana 创建一个kibana容器并起一个名字
   > -p 5601:5601 将linux的5601端口映射到docker容器的5601端口，用来给kibana发送http请求
   > -v 挂载命令，将虚拟机中的路径和docker中的路径进行关联
   > -d 后台启动服务

8. 查看是否运行成功

   ```
   docker ps | grep kibana
   ```

9. 查看启动日志

   ```
   docker logs kibana
   ```

10. 在浏览器地址栏访问 http://ip:5601 ，进入到kibana的控制台

   