---
author: 江峰
title: "docker启动ElasticSearch"
date: 2022-08-03 22:15
comments: true
categories: docker
summary: 通过docker启动ElasticSearch。
tags: 
	- docker

---

https://blog.csdn.net/qq_36079077/article/details/112858403

# docker启动ElasticSearch

1. 查询ElasticSearch镜像

   ```
   docker search elasticsearch:7.6.0 
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull elasticsearch:7.6.0 
   ```

3. 查看ElasticSearch镜像

   ```
   docker images  | grep elasticsearch
   ```

4. 创建实例
   ```
   mkdir -p /mydata/elasticsearch/config # 在mydata文件夹下创建es的config文件夹，将docker中es的配置挂载在外部，当我们在linux虚拟机中修改es的配置文件时，就会同时修改docker中的es的配置
mkdir -p /mydata/elasticsearch/data #在mydata文件夹下创建es的data文件夹
echo "http.host:0.0.0.0" >> /mydata/elasticsearch/config/elasticsearch.yml # [http.host:0.0.0.0]允许任何远程机器访问es，并将其写入es的配置文件中
chmod -R 777 /mydata/elasticsearch/ # 保证权限问题

   ```
5. 使用docker运行ElasticSearch

   ```
   docker run -p 3306:3306 --name ElasticSearch-3306 -e ElasticSearch_ROOT_PASSWORD=123456 -d ElasticSearch
   ```

   命令解释说明：

   -p 8848:8848 端口映射：前表示主机部分，：后表示容器部分。

   --name ElasticSearch-3306  指定该容器名称，查看和进行操作都比较方便。

   -e ElasticSearch_ROOT_PASSWORD=123456：docker的ElasticSearch默认的root密码是随机的，这是改一下默认的root用户密码

   -d ElasticSearch：在后台运行ElasticSearch镜像产生的容器

   

5. 查看是否运行成功

   ```
   docker ps | grep ElasticSearch
   ```

   

6. 通过navicat连接ElasticSearch出现2059的问题

   **原因**：8.0之后ElasticSearch更改了密码的加密规则，只要在命令窗口把加密方法改回去即可。

   **解决办法**：

   1. 进入到docker容器里面的ElasticSearch

      ```
      docker exec -it ElasticSearch-3306 bash
      ```

   2. 进去之后不用切换目录。直接输入下面的命令登录ElasticSearch

      ```
      ElasticSearch -uroot -p123456
      ```

   3. 然后运行以下SQL

      ```
      alter user 'root'@'%' identified by '123456' password expire never;
      alter user 'root'@'%' identified with ElasticSearch_native_password by '123456';
      flush privileges;
      ```

   4. 重新启动docker里面的ElasticSearch容器

      ```
      docker restart ElasticSearch-3306
      ```

      

7. 通过navicat客户端重新连接即可