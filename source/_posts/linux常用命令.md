---
author: 江峰
title: "linux常用命令"
date: 2021-03-26 10:55
comments: true
categories: linux
summary: 对linux里面常用的命令进行总结
tags: 
	- linux
---

### 

## 一、查看文本





## 二、搜索文本里面的内容





## 三、端口号

 1. ### 查看端口号是否在使用：

    lsof -i:8080

2. ### 对外部开放端口号

   **查询指定端口是否已经开放**
   firewall-cmd --query-port=3306/tcp
   返回yes/no。此时也有可能返回firewalld is not running，此时需要打开防火墙在开放端口。

   

   **添加指定需要开放的端口：**
   firewall-cmd --add-port=3306/tcp --permanent

   

   **载入添加的端口：**
   firewall-cmd --reload

   

## 四、防火墙

1. 查看防火墙状态 systemctl status firewalld

2. 开启防火墙 systemctl start firewalld

3. 关闭防火墙 systemctl stop firewalld

   

## 五、内存

​	free -h



## 六、磁盘

​	 df -h