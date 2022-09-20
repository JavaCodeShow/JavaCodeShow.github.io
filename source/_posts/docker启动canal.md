---
author: 江峰
title: "docker启动Canal"
date: 2022-09-07 22:15
comments: true
categories: docker
summary: 通过docker启动Canal
tags: 
	- docker

---

# docker启动Canal



1. 先安装mysql，见：https://007code.cn/2020/05/22/docker-qi-dong-mysql/

   ```
   show variables like 'log_bin';
   
   show binary logs;
   
   show master status;
   ```
   
2. ```
   CREATE USER canal IDENTIFIED BY 'canal';    
   GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';  
   -- GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;  
   FLUSH PRIVILEGES; 
   
   show grants for 'canal' 
   
   ```

3. 



1. 查询Canal镜像

   ```
   docker search canal
   ```

2. 从docker hub拉取最新镜像

   ```
   docker pull canal/canal-server
   ```

3. 查看Canal镜像

   ```
   docker images | grep canal
   ```

4.  拉去完成后，先启动下canal，主要是为了从里面copy出配置文件

   ```
   #启动镜像 
   docker run --name canal -d canal/canal-server
   
   #进入容器 查看配置文件路径
   docker exec -it canal bash
    
   #找到文件位置后 exit退出容器 将容器内部文件copy到外部
   docker cp canal:/home/admin/canal-server/conf/canal.properties /usr/java/docker/canal
   docker cp canal:/home/admin/canal-server/conf/example/instance.properties  /usr/java/docker/canal
   ```

   

5. 修改instance.properties

   ```
   ```

6. 修改canal.properties

   ```
   
   ```

7. 修改完成后，将之前的canal容器关闭，重新起一个新的容器

   ```
   #强制移除容器
   docker rm -f canal
    
   #启动新的 这里-v是将外部的文件挂载到容器内部 这样就不用每次启动都要配置参数了
   docker run --name canal -p 11111:11111 -d \
   -v /usr/java/docker/canal/instance.properties:/home/admin/canal-server/conf/example/instance.properties \
   -v /usr/java/docker/canal/canal.properties:/home/admin/canal-server/conf/canal.properties \
   -v /usr/java/docker/canal/logs/:/home/admin/canal-server/logs/ \
   canal/canal-server
   ```
   
8. 查看是否运行成功

   ```
   docker ps | grep canal
   ```

9. 查看启动日志

   ```
   docker logs canal
   ```

   