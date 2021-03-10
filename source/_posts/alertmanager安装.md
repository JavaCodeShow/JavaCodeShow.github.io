---

author: 江峰
title: "alertmanager安装教程"
date: 2020-07-01 10:55
comments: true
categories: prometheus
summary: 使用alertmanager进行监控告警。
tags: 

	- prometheus

---



## 1. 下载Alertmanager

alertmanager官方网站下载
[https://prometheus.io/download/#alertmanager](https://prometheus.io/download/#alertmanager)
```
wget https://github.com/prometheus/alertmanager/releases/download/v0.17.0/alertmanager-0.17.0.linux-amd64.tar.gz
tar xvf alertmanager-0.17.0.linux-amd64.tar.gz
mv alertmanager-0.17.0.linux-amd64 /usr/local/alertmanager
```
## 2. 启动Alertmanager
linux 中启动alertmanager命令
cd进入到alertmanager根目录

```
./alertmanager --config.file=alertmanager.yml
```

## 3. 查看Alertmanager运行状态
Alertmanager启动后可以通过9093端口访问，http://ip:9093

## 4. Prometheus中配置Alertmanager
**修改prometheus.yml**,配置alertmanager的地址。

```
alerting:
 alertmanagers:
 - static_configs:
   - targets: ["localhost:9093"] 
```
至此。prometheus产生告警后将会发送给prometheus。
注意点：
1. 需要配置告警规则。
2. alertmanager配置文件需要配置收到告警后对告警的处理方式。
这个在本专栏的其他文章中讲解。