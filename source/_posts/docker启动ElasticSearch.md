---
author: 江峰
title: "docker启动ElasticSearch"
date: 2022-08-03 22:15
comments: true
categories: docker
summary: 通过docker启动ElasticSearch
tags: 
	- docker

---

# docker启动ElasticSearch

1. 查询ElasticSearch镜像

   ```
   docker search elasticsearch
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull elasticsearch:7.6.0 
   ```

3. 查看ElasticSearch镜像

   ```
   docker images | grep elasticsearch
   ```

4. 配置文件

   在mydata（系统根目录即可）文件夹下创建es的config文件夹，将docker中es的配置挂载在外部，当我们在linux虚拟机中修改es的配置文件时，就会同时修改docker中的es的配置

   ```
   mkdir -p /usr/java/docker/elasticsearch/config
   ```

   在mydata文件夹下创建es的data文件夹

   ```
   mkdir -p /usr/java/docker/elasticsearch/data
   ```

   [http.host:0.0.0.0]允许任何远程机器访问es，并将其写入es的配置文件中

   ```
   echo "http.host: 0.0.0.0" >> /usr/java/docker/elasticsearch/config/elasticsearch.yml
   ```

   查看配置文件

   ```
   cat /usr/java/docker/elasticsearch/config/elasticsearch.yml
   ```

   保证权限问题

   ```
   chmod -R 777 /usr/java/docker/elasticsearch
   ```

   

5. 使用docker运行ElasticSearch

   ```
   docker run --name elasticsearch -p 9200:9200 -p 9300:9300 \
   -e "discovery.type=single-node" \
   -e ES_JAVA_OPTS="-Xms64m -Xmx128m" \
   -v /usr/java/docker/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
   -v /usr/java/docker/elasticsearch/data:/usr/share/elasticsearch/data \
   -v /usr/java/docker/elasticsearch/plugins:/usr/share/elasticsearch/plugins \
   -d elasticsearch:7.6.0
   ```

   > 命令解释说明：
   >
   > docker run --name elasticsearch 创建一个es容器并起一个名字
   > -p 9200:9200 将linux的9200端口映射到docker容器的9200端口，用来给es发送http请求
   > -p 9300:9300 9300是es在分布式集群状态下节点之间的通信端口 
   > -e 指定jvm内存，当前es以单节点模式运行
   > -v 挂载命令，将虚拟机中的路径和docker中的路径进行关联
   > -d 后台启动服务

   >注意：ES_JAVA_OPTS非常重要，指定开发时es运行时的最小和最大内存占用为64M和128M，否则就	会占用全部可用内存

6. 查看是否运行成功

   ```
   docker ps | grep elasticsearch
   ```

7. 查看启动日志

   ```
   docker logs elasticsearch
   ```

8. 在浏览器地址栏访问http://ip:9200/，可以看到 es 启动成功后返回类似下面的数据

   ```
   {
     "name": "3717e262d33f",
     "cluster_name": "elasticsearch",
     "cluster_uuid": "njGUk4ruRDSQHT4xZTzB3A",
     "version": {
       "number": "7.6.0",
       "build_flavor": "default",
       "build_type": "docker",
       "build_hash": "7f634e9f44834fbc12724506cc1da681b0c3b1e3",
       "build_date": "2020-02-06T00:09:00.449973Z",
       "build_snapshot": false,
       "lucene_version": "8.4.0",
       "minimum_wire_compatibility_version": "6.8.0",
       "minimum_index_compatibility_version": "6.0.0-beta1"
     },
     "tagline": "You Know, for Search"
   }
   ```