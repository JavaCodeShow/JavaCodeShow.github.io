---
author: 江峰
title: "linux安装RocketMQ"
date: 2021-03-31 16:51
comments: true
categories: RocketMQ
summary: linux安装RocketMQ
tags: 
	- RocketMQ
---

# linux安装RocketMQ

前提条件：RocketMQ是基于java语言开发的。运行RocketMQ需要java环境。JDK的版本应该 >= 1.8。请确保安装了JDK。

查看方式：

```
[root@iZuf6j6c7vo33inl2830e3Z rocketmq]# java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

本人用的是阿里云服务器。JDK版本是1.8，maven版本是3.6.3

## 一、下载RocketMQ

该地址列出了RocketMQ所有发布的版本：https://archive.apache.org/dist/rocketmq/

这里将RocketMQ安装到Linux文件系统的/usr/java/rocketmq目录

```bash
cd /usr/java/rocketmq
```

下载之后进行解压缩：

```bash
unzip rocketmq-all-4.8.0-bin-release.zip
```

这边将目录名字修改一下,解压完毕也就不需要了，删除zip包

```
rm -rf rocketmq-all-4.8.0-bin-release.zip
mv rocketmq-all-4.8.0-bin-release rocketmq
```

解压目录说明

```bash
rocketmq
	├── benchmark #性能测试脚本
	├── bin       #命令行工具
	├── conf      #配置文件目录
	├── lib       #依赖的第三方类库
	├── LICENSE
	├── NOTICE
	└── README.md
```



## 二、启动RocketMQ

### 2.1 启动NameServer

* 启动NameServer

  ```
  nohup sh bin/mqnamesrv >/dev/null &
  ```

* 查看NameServer启动日志

  ```
  tail -500f ~/logs/rocketmqlogs/namesrv.log
  ```

### 2.2 启动Broker

* 启动broker

  ```
  nohup sh bin/mqbroker -n localhost:9876 >/dev/null &
  ```

* 查看Broker启动日志

  ```
  tail -500f ~/logs/rocketmqlogs/broker.log 
  ```

### 2.3 启动失败内存问题解决

* 这里发现会由于内存不足启动失败

  RocketMQ默认的虚拟机内存较大，启动NameServer和Broker如果因为内存不足失败，需要编辑如下两个配置文件，修改JVM内存大小

  ```
  # 编辑runbroker.sh和runserver.sh修改默认JVM大小
  vi runbroker.sh
  vi runserver.sh
  ```

* 参考设置：

  ``` 
  JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MetaspaceSize=128m  -XX:MaxMetaspaceSize=320m"
  ```

改完保存重新启动即可。查看启动日志验证是否成功。

也可以通过jps- l 来验证

```
[root@iZuf6j6c7vo33inl2830e3Z rocketmq]# jps -l
20358 org.apache.rocketmq.broker.BrokerStartup
19965 org.apache.rocketmq.namesrv.NamesrvStartup
22349 sun.tools.jps.Jps
```

### 2.4 测试RocketMQ

* 发送消息：使用安装包的Demo发送消息

  ```
  sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer
  ```
  
* 接收消息

  ```
  sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer
  ```
  


### 2.5 关闭RocketMQ

* 关闭NameServer

  ```
  sh bin/mqshutdown namesrv
  ```

* 关闭Broker

  ```
  sh bin/mqshutdown broker
  ```

  

## 三、RocketMQ集群搭建

一个完整的RocketMQ集群由NameServer集群，Broker集群，Producer集群，Consumer集群组成。本节主要介绍NameServer集群，Broker集群的搭建。

- NameServer是一个几乎无状态节点，可集群部署，节点之间无任何信息同步。

- Broker部署相对复杂，Broker分为Master与Slave，一个Master可以对应多个Slave，但是一个Slave只能对应一个Master，Master与Slave的对应关系通过指定相同的BrokerName，不同的BrokerId来定义，BrokerId为0表示Master，非0表示Slave。Master也可以部署多个。每个Broker与NameServer集群中的所有节点建立长连接，定时注册Topic信息到所有NameServer。
- Producer与NameServer集群中的其中一个节点（随机选择）建立长连接，定期从NameServer取Topic路由信息，并向提供Topic服务的Master建立长连接，且定时向Master发送心跳。Producer完全无状态，可集群部署。
- Consumer与NameServer集群中的其中一个节点（随机选择）建立长连接，定期从NameServer取Topic路由信息，并向提供Topic服务的Master、Slave建立长连接，且定时向Master、Slave发送心跳。Consumer既可以从Master订阅消息，也可以从Slave订阅消息，订阅规则由Broker配置决定。

### 3.1 集群模式

#### 1）单Master模式

这种方式风险较大，一旦Broker重启或者宕机时，会导致整个服务不可用。不建议线上环境使用,可以用于本地测试。

#### 2）多Master模式

一个集群无Slave，全是Master，例如2个Master或者3个Master，这种模式的优缺点如下：

- 优点：配置简单，单个Master宕机或重启维护对应用无影响，在磁盘配置为RAID10时，即使机器宕机不可恢复情况下，由于RAID10磁盘非常可靠，消息也不会丢（异步刷盘丢失少量消息，同步刷盘一条不丢），性能最高；
- 缺点：单台机器宕机期间，这台机器上未被消费的消息在机器恢复之前不可订阅，消息实时性会受到影响。

#### 3）多Master多Slave模式（异步）

每个Master配置一个Slave，有多对Master-Slave，HA采用异步复制方式，主备有短暂消息延迟（毫秒级），这种模式的优缺点如下：

- 优点：即使磁盘损坏，消息丢失的非常少，且消息实时性不会受影响，同时Master宕机后，消费者仍然可以从Slave消费，而且此过程对应用透明，不需要人工干预，性能同多Master模式几乎一样；
- 缺点：Master宕机，磁盘损坏情况下会丢失少量消息。

#### 4）多Master多Slave模式（同步）

每个Master配置一个Slave，有多对Master-Slave，HA采用同步双写方式，即只有主备都写成功，才向应用返回成功，这种模式的优缺点如下：

- 优点：数据与服务都无单点故障，Master宕机情况下，消息无延迟，服务可用性与数据可用性都非常高；
- 缺点：性能比异步复制模式略低（大约低10%左右），发送单个消息的RT会略高，且目前版本在主节点宕机后，备机不能自动切换为主机。



### 3.2 环境变量配置

```
vim /etc/profile
```

在profile文件的末尾加入如下命令

```
#set rocketmq
ROCKETMQ_HOME=/usr/java/rocketmq
PATH=$PATH:$ROCKETMQ_HOME/bin
export ROCKETMQ_HOME PATH
```

输入:wq! 保存并退出， 并使得配置立刻生效：

```
source /etc/profile
```



### 3.3 防火墙配置

宿主机需要远程访问虚拟机的rocketmq服务和web服务，需要开放相关的端口号，简单粗暴的方式是直接关闭防火墙

```bash
# 关闭防火墙
systemctl stop firewalld.service 
# 查看防火墙的状态
firewall-cmd --state 
# 禁止firewall开机启动
systemctl disable firewalld.service
```

或者为了安全，只开放特定的端口号，RocketMQ默认使用3个端口：9876 、10911 、11011 。如果防火墙没有关闭的话，那么防火墙就必须开放这些端口：

* `nameserver` 默认使用 9876 端口
* `master` 默认使用 10911 端口
* `slave` 默认使用11011 端口

执行以下命令：

```bash
# 开放name server默认端口
firewall-cmd --remove-port=9876/tcp --permanent
# 开放master默认端口
firewall-cmd --remove-port=10911/tcp --permanent
# 开放slave默认端口 (当前集群模式可不开启)
firewall-cmd --remove-port=11011/tcp --permanent 
# 重启防火墙
firewall-cmd --reload
```



### 3.3 单Master模式

#### 3.3.1 创建消息存储路径

系统根目录执行一下命令

```
cd /
mkdir -p /data/rocketmq/single-master/broker-a/store
mkdir -p /data/rocketmq/single-master/broker-a/store/commitlog
mkdir -p /data/rocketmq/single-master/broker-a/store/consumequeue
mkdir -p /data/rocketmq/single-master/broker-a/store/index
mkdir -p /data/rocketmq/single-master/broker-a/store/checkpoint
mkdir -p /data/rocketmq/single-master/broker-a/store/abort
```



#### 3.3.2  修改broker配置文件

```
vi /usr/java/rocketmq/conf/broker.conf
```

```
#所属集群名字
brokerClusterName=single-master
#broker名字，注意此处不同的配置文件填写的不一样
brokerName=broker-a
#0 表示 Master，>0 表示 Slave
brokerId=0
#nameServer地址，分号分割
namesrvAddr=1.15.226.249:9876
# 你的公网IP
brokerIP1=1.15.226.249
#在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
defaultTopicQueueNums=4
#是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=true
#是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true
#Broker 对外服务的监听端口
listenPort=10911
#删除文件时间点，默认凌晨 4点
deleteWhen=04
#文件保留时间，默认 48 小时
fileReservedTime=48
#commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824
#ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
#检测物理文件磁盘空间
diskMaxUsedSpaceRatio=88
#存储路径
storePathRootDir=/data/rocketmq/single-master/broker-a/store
#commitLog 存储路径
storePathCommitLog=/data/rocketmq/single-master/broker-a/store/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/data/rocketmq/single-master/broker-a/store/consumequeue
#消息索引存储路径
storePathIndex=/data/rocketmq/single-master/broker-a/store/index
#checkpoint 文件存储路径
storeCheckpoint=/data/rocketmq/single-master/broker-a/store/checkpoint
#abort 文件存储路径
abortFile=/data/rocketmq/single-master/broker-a/store/abort
#限制的消息大小
maxMessageSize=65536
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#Broker 的角色
#- ASYNC_MASTER 异步复制Master
#- SYNC_MASTER 同步双写Master
#- SLAVE
brokerRole=ASYNC_MASTER
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=ASYNC_FLUSH
#checkTransactionMessageEnable=false
#发消息线程池数量
sendMessageThreadPoolNums=18
#拉消息线程池数量
pullMessageThreadPoolNums=18
```



#### 3.3.3 启动

* 启动NameServer

  ```
  nohup sh bin/mqnamesrv >/dev/null &
  ```

* 查看NameServer启动日志

  ```
  tail -500f ~/logs/rocketmqlogs/namesrv.log
  ```

* 启动broker

  ```
  nohup sh bin/mqbroker -c conf/broker.conf >/dev/null &
  ```

* 查看Broker启动日志

  ```
  tail -500f ~/logs/rocketmqlogs/broker.log 
  ```

* 关闭NameServer

  ```
  sh bin/mqshutdown namesrv
  ```

* 关闭Broker

  ```
  sh bin/mqshutdown broker
  ```


注意：broker启动时不会读取broker.conf中的配置，尽管也可以启动，但是如果需要使得配置文件生效，必须通过-c参数进行指定。

验证启动成功

```
[root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# jps -l
1354 org.apache.rocketmq.namesrv.NamesrvStartup
1739 org.apache.rocketmq.broker.BrokerStartup
[root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# 
```

#### 3.3.4 查看集群列表信息

```bash
$ sh bin/mqadmin clusterList -n 1.15.226.249:9876
#Cluster Name    #Broker Name   #BID        #Addr           #Version   #...(略)
single-master    broker-a      0        192.168.1.3:10911     V4_6_0    …
```

输出的每一列说明如下：

- Cluster Name：集群的名称，即brokerClusterName配置项的值
- Broker Name：Broker的名称，即brokerName配置项的值
- BID：Broker的ID，这里显示为0，即brokerId配置项的值
- Addr：监听的IP/端口，供生产者/消费者访问，端口即listenPort配置项的值
- Version：broker的版本



## 四、RocketMQ控制台安装

下载代码并编译打包

```
git clone https://github.com/apache/rocketmq-externals
cd rocketmq-console
mvn clean package -Dmaven.test.skip=true
```

注意：打包前在```rocketmq-console```中配置```namesrv```集群地址：

```sh
rocketmq.config.namesrvAddr=1.15.226.249:9876
```

最好将server.port也修改一下。默认是8080。

上传到linux服务器任意一个目录。

启动rocketmq-console：

```sh
nohup java -jar rocketmq-console-ng-2.0.0.jar >/dev/null &
```

启动成功后，我们就可以通过浏览器访问`http://公网ip:port



## 五、遇到的问题

1. 启动broker失败

   ```
   2020-8-24 13:11:11 INFO main - Try to shutdown service thread:AllocateMappedFileService started:true lastThread:Thread[AllocateMappedFileService,5,main]
   2020-8-24 13:11:11 INFO main - shutdown thread AllocateMappedFileService interrupt true
   2020-8-24 13:11:11 INFO main - join thread AllocateMappedFileService elapsed time(ms) 5 90000
   2020-8-24 13:11:11 INFO main - Try to shutdown service thread:PullRequestHoldService started:false lastThread:null
   ```

   解决原因：将broker的存储路径storePathRootDir给注释掉。使用broker默认的存储路径（/root/store）。

   可以临时解决一下。这不是很好的解决方案。具体原因未找出来。

2. producer没有连接上broker

   ```
   com.alibaba.rocketmq.remoting.exception.RemotingConnectException: connect to <127.0.0.1:9876> failed
   ```

   这个修改broker的配置文件。需要修改两个参数

   ```
   # 你的公网IP
   namesrvAddr=1.15.226.249:9876
   # 你的公网IP，不指定就是127.0.0.1。而127.0.0.1在外网环境中无法访问。
   brokerIP1=1.15.226.249
   ```

   rocketmq控制台也是如此。需要指定namesrvAddr的外网ip。







