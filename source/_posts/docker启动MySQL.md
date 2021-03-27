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



# docker启动MySQL

1. 查询mysql镜像

   ```
   docker search mysql
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull mysql
   ```

3. 查看mysql镜像

   ```
   docker images  | grep mysql
   ```

4. 使用docker运行mysql

   ```
   docker run -p 3306:3306 --name mysql-3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql
   ```

   命令解释说明：

   -p 8848:8848 端口映射：前表示主机部分，：后表示容器部分。

   --name mysql-3306  指定该容器名称，查看和进行操作都比较方便。

   -e MYSQL_ROOT_PASSWORD=123456：docker的MySQL默认的root密码是随机的，这是改一下默认的root用户密码

   -d mysql：在后台运行mysql镜像产生的容器

   

5. 查看是否运行成功

   ```
   docker ps | grep mysql
   ```

   

6. 通过navicat连接mysql出现2059的问题

   **原因**：8.0之后mysql更改了密码的加密规则，只要在命令窗口把加密方法改回去即可。

   **解决办法**：

   1. 进入到docker容器里面的mysql

      ```
      docker exec -it mysql-3306 bash
      ```

   2. 进去之后不用切换目录。直接输入下面的命令登录MySQL

      ```
      mysql -uroot -p123456
      ```

   3. 然后运行以下SQL

      ```
      alter user 'root'@'%' identified by '123456' password expire never;
      alter user 'root'@'%' identified with mysql_native_password by '123456';
      flush privileges;
      ```

   4. 重新启动docker里面的mysql容器

      ```
      docker restart mysql-3306
      ```

      

7. 通过navicat客户端重新连接即可