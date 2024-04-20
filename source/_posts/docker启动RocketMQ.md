---
author: 江峰
title: "docker启动RocketMQ"
date: 2023-11-11 22:15
comments: true
categories: docker
summary: 通过docker启动RocketMQ。
tags: 
	- docker

---

<meta name="referrer" content="no-referrer" />

# docker启动RocketMQ

**单机模式**

## 1. 安装NameServer

1. 下载镜像

   ```
    docker pull rocketmqinc/rocketmq
   ```

2. 查看镜像

   ```
   docker images | grep rocketmqinc/rocketmq
   ```

3. 创建挂载文件目录

   ```
   mkdir -p /usr/java/docker/rocketmq/namesrv && mkdir -p /usr/java/docker/rocketmq/broker
   ```

4. 启动nameserver

   ```
   docker run -d -p 9876:9876 --name mqserver \
   -e "JAVA_OPT_EXT=-Xms256M -Xmx256M -Xmn128m" \
   -v /usr/java/docker/rocketmq/namesrv/logs:/root/logs \
   -v /usr/java/docker/rocketmq/namesrv/store:/root/store \
   -m 512m \
   --network host \
   rocketmqinc/rocketmq:latest \
   sh mqnamesrv
   ```

5. 查看是否启动成功

   ```
   docker ps -a | grep mqserver
   ```

6. 查看日志

   ```
   tail -500f /usr/java/docker/rocketmq/namesrv/logs/rocketmqlogs/namesrv.log
   ```

## 2. 启动Broker

1. 复制broker.conf文件

   ```
   # 先创建一个临时的broker容器
   docker run -d -p 10911:10911 -p 10909:10909 --name mqbroker \
   rocketmqinc/rocketmq:latest \
   sh mqbroker -n localhost:9876
   
   # 复制broker.conf
   docker cp mqbroker:/opt/rocketmq-4.4.0/conf/broker.conf /usr/java/docker/rocketmq/broker/broker.conf
   
   ```

2. 修改broker.conf

   ```
   
   brokerClusterName = DefaultCluster
   brokerName = broker-a
   brokerId = 0
   deleteWhen = 04
   fileReservedTime = 48
   brokerRole = ASYNC_MASTER
   flushDiskType = ASYNC_FLUSH
   # 公网ip
   namesrvAddr=172.31.128.22:9876
   brokerIP1=172.31.128.22.249
   #在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
   defaultTopicQueueNums=4
   #是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
   autoCreateTopicEnable=true
   #是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
   autoCreateSubscriptionGroup=true
   ```
   
3. 删除容器

   ```
   docker rm -f mqbroker
   ```

4. 启动Broker

   ```
   docker run -d -p 10911:10911 -p 10909:10909 --name mqbroker \
   -v /usr/java/docker/rocketmq/broker/logs:/root/logs \
   -v /usr/java/docker/rocketmq/broker/store:/root/store \
   -v /usr/java/docker/rocketmq/broker/broker.conf:/opt/rocketmq-4.4.0/conf/broker.conf \
   -e "JAVA_OPT_EXT=-Xms256M -Xmx256M -Xmn128m" \
   -m 512m \
   --network host \
   rocketmqinc/rocketmq:latest sh mqbroker -c /opt/rocketmq-4.4.0/conf/broker.conf
   ```

5. 查看是否启动成功

   ```
   docker ps -a | grep mqbroker
   ```

6. 查看日志

   ```
   tail -500f /usr/java/docker/rocketmq/broker/logs/rocketmqlogs/broker.log
   ```

## 3. 安装控制台

1. 下载镜像

   ```
   docker pull apacherocketmq/rocketmq-dashboard:latest
   ```

2. 启动控制台

   ```
   docker run -p 8087:8080 --name mqconsole -d \
   -e "JAVA_OPTS=-Drocketmq.namesrv.addr=172.31.128.22:9876" \
   -m 512m \
   -t apacherocketmq/rocketmq-dashboard
   ```

3. 查看是否启动成功

   ```
   docker ps -a | grep mqconsole
   ```

4. 查看日志

   ```
   docker logs mqconsole
   ```
