---

layout: post
title: "kafka入门基本使用命令"
date: 2020-05-07 10:55
comments: true
tags: 
	- kafka
---



学习了kafka相关的知识，一直没有进行总结。在这里将一些简单的命令进行记录下来。

​    <!-- more -->

## 一 修改配置文件

在kafka解压目录下下有一个config的文件夹，里面放置的是我们的配置文件　　

1. consumer.properites 消费者配置，此处我们使用默认的即可
2. producer.properties 生产者配置，此处我们使用默认的即可
3. server.properties kafka服务器的配置，此配置文件用来配置kafka服务器，
4. broker.id 申明当前kafka服务器在集群中的唯一ID，需配置为integer,并且集群中的每一个kafka服务器的id都应是唯一的，我们这里采用默认配置即可
5. listeners 申明此kafka服务器需要监听的端口号，如果是在本机上跑虚拟机运行可以不用配置本项，默认会使用localhost的地址。如果是在远程服务器上运行则必须配置，例如：listeners=PLAINTEXT:// 192.168.180.128:9092。并确保服务器的9092端口能够访问，如果想外部电脑上的程序也能访问此kafka，就必须指定ip地址，不然java中会报key为null的错误。zookeeper.connect 申明kafka所连接的zookeeper的地址 ，需配置为zookeeper的地址，由于本次使用的是kafka高版本中自带zookeeper，使用默认配置即可zookeeper.connect=localhost:2181

```
修改server.properties
本机使用：
        listeners=PLAINTEXT://localhost:9092
        advertised.listeners=PLAINTEXT://localhost:9092 
远程使用
 		listeners=PLAINTEXT://内网ip:9092
        advertised.listeners=PLAINTEXT://公网ip:9092 
```

##  二 运行

### 2.1 启动zookeeper
cd进入kafka解压目录，输入

```
bin/zookeeper-server-start.sh config/zookeeper.properties
```

### 2.2 启动kafka

cd进入kafka解压目录，输入

```
bin/kafka-server-start.sh config/server.properties
```

**kafka后台运行**

```
bin/kafka-server-start.sh config/server.properties &
```

### 2.3 创建topic

创建一个名为test的topic　

```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test　
```

### 2.4 查看topic

```
bin/kafka-topics.sh --list --zookeeper localhost:2181
```

### 2.5 创建消费者

可以创建一个用于消费topic为test的消费者，加上--from-beginning表示从开始所有的消息都显示出来

在kafka解压目录打开终端，输入

```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

### 2.6 创建一个消息生产者

在kafka解压目录打开一个新的终端，输入

```
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
```

### 2.7 删除topic

```
bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic accreditNotify
```





