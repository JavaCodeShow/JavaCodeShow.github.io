---
author: 江峰
title: "docker启动MySQL"
date: 2020-05-22 22:15
comments: true
categories: docker
summary: 通过docker启动MySQL。
tags: 
	- docker

---

<meta name="referrer" content="no-referrer" />

# docker启动MySQL

1. 查询mysql镜像

   ```
   docker search mysql
   ```

2. 从docker hub拉取镜像

   ```
   docker pull mysql:8.0.28
   ```

3. 查看mysql镜像

   ```
   docker images  | grep mysql
   ```

4. 复制文件

   ```
   #创建目录
   mkdir -p /usr/java/docker/mysql/conf && mkdir -p /usr/java/docker/mysql/data && mkdir -p /usr/java/docker/mysql/logs
   
   #启动容器，为了复制文件
   docker run -p 3306:3306 --name mysql -d -e MYSQL_ROOT_PASSWORD=“123456” mysql:8.0.28
   
   #复制文件
   docker cp mysql:/etc/mysql/my.cnf /usr/java/docker/mysql/conf
   
   #删除容器
   docker rm -f mysql
   ```

5. 使用docker运行mysql

   ```
   docker run -p 3306:3306 --name mysql \
   -v /usr/java/docker/mysql/logs:/var/log/mysql \
   -v /usr/java/docker/mysql/data:/var/lib/mysql \
   -v /usr/java/docker/mysql/conf:/etc/mysql/conf.d \
   -e MYSQL_ROOT_PASSWORD=123456 \
   --restart=always \
   --privileged=true \
   -v /etc/localtime:/etc/localtime \
   -m 512m \
   -d \
   mysql:8.0.28
   ```

   命令解释说明：

   -p 8848:8848 端口映射：前表示主机部分，：后表示容器部分。

   --name mysql  指定该容器名称，查看和进行操作都比较方便。

   -e MYSQL_ROOT_PASSWORD=123456：docker的MySQL默认的root密码是随机的，这是改一下默认的root用户密码

   -v /etc/localtime:/etc/localtime：共享主机的 localtime

   -d mysql:8.0.28   在后台运行mysql镜像产生的容器

   

6. 查看是否运行成功

   ```
   docker ps | grep mysql
   ```

   

7. 通过navicat连接mysql出现2059的问题

   **原因**：8.0之后mysql更改了密码的加密规则，只要在命令窗口把加密方法改回去即可。

   **解决办法**：

   1. 进入到docker容器里面的mysql

      ```
      docker exec -it mysql bash
      ```

   2. 进去之后不用切换目录。直接输入下面的命令登录MySQL

      ```
      mysql -uroot -p123456
      ```

   3. 然后运行以下SQL

      ```
      alter user 'root'@'%' identified by 'mimazhaowoyao' password expire never;
      alter user 'root'@'%' identified with mysql_native_password by 'mimazhaowoyao';
      flush privileges;
      ```

   4. 重新启动docker里面的mysql容器

      ```
      docker restart mysql
      ```

      

8. 通过navicat客户端重新连接即可