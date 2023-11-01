---
author: 江峰
title: "prometheus告警规则配置"
date: 2020-07-01 10:55
comments: true
categories: prometheus
summary: prometheus告警规则配置。
tags: 
	- prometheus

---

<meta name="referrer" content="no-referrer" />

## 1. 创建告警规则配置文件

创建告警规则配置文件first_rules.yml，建议放在与prometheus.yml同级目录

## 2. 修改prometheus配置文件
修改配置文件prometheus.yml，将告警规则配置文件添加到prometheus.yml。注意路径。
```
global:
  scrape_interval:     15s   # 这个是每次数据手机的频率
  evaluation_interval: 15s   # 评估告警规则的频率。
  
# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
       - 'localhost:9093'
     
rule_files:
    - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:               # 通过这里的配置控制prometheus监控的资源
  - job_name: prometheus      # prometheus自身默认的
    static_configs:
      - targets: ['localhost:9090']  # 默认暴露的是9090端口服务
```

## 3. 配置告警规则文件
>在告警规则文件中，我们可以将一组相关的规则设置定义在一个group下。在每一个group中我们可以定义多个告警规则(rule)。一条告警规则主要由以下几部分组成：
>**alert**：告警规则的名称。
> **expr**：基于PromQL表达式告警触发条件，用于计算是否有时间序列满足该条件。
>**for**：评估等待时间，可选参数。用于表示只有当触发条件持续一段时间后才发送告警。在等待期间新产生告警的状态为pending。
>**labels**：自定义标签，允许用户指定要附加到告警上的一组附加标签。
>**annotations**：用于指定一组附加信息，比如用于描述告警详细信息的文字等，annotations的内容在告警产生时会一同作为参数发送到Alertmanager。summary描述告警的概要信息，description用于描述告警的详细信息。同时Alertmanager的UI也会根据这两个标签值，显示告警信息。

这里配置中的acs-ms为应用名字。也就是job的名字
### 监控应用是否宕机，
```
alert: serverDown
expr: up{job="acs-ms"}  ==  0
for: 1m
labels:
  severity: critical
annotations:
  description: 实例：{{ $labels.instance }} 宕机了
  summary: Instance {{ $labels.instance }} down
```
### 监控接口发生异常
```
alert: interface_request_exception
expr: increase(http_server_requests_seconds_count{exception!="None",exception!="ServiceException",job="acs-ms"}[1m])
  > 0
for: 1s
labels:
  severity: page
annotations:
  description: '实例：{{ $labels.instance }}的{{$labels.uri}}的接口发生了{{ $labels.exception
    }}异常 '
  summary: 监控一定时间内接口请求异常的数量
```
>**exception!="ServiceException"** 是将一些手动抛出的自定义异常给排除掉。

### 监控接口请求时长
```
alert: interface_request_duration
expr: increase(http_server_requests_seconds_sum{exception="None",job="acs-ms",uri!~".*Excel.*"}[1m])
  / increase(http_server_requests_seconds_count{exception="None",job="acs-ms",uri!~".*Excel.*"}[1m])
  > 5
for: 5s
labels:
  severity: page
annotations:
  description: '实例：{{ $labels.instance }} 的{{$labels.uri}}接口请求时长超过了设置的阈值：5s，当前值{{
    $value }}s '
  summary: 监控一定时间内的接口请求时长
```
>**uri!~".*Excel.*"** 是将一些接口给排除掉。这个是将包含Excel的接口排除掉。

### 监测系统CPU使用的百分比
```
alert: CPUTooHeight
expr: process_cpu_usage{job="acs-ms"} > 0.3
for: 15s
labels:
  severity: page
annotations:
  description: '实例：{{ $labels.instance }} 的cpu超过了设置的阈值：30%，当前值{{ $value }} '
  summary: 监测系统CPU使用的百分比
```

### 监控tomcat活动线程占总线程的比例
```
alert: tomcat_thread_height
expr: tomcat_threads_busy_threads{job="acs-ms"}
  / tomcat_threads_config_max_threads{job="acs-ms"} > 0.5
for: 15s
labels:
  severity: page
annotations:
  description: '实例：{{ $labels.instance }} 的tomcat活动线程占总线程的比例超过了设置的阈值：50%，当前值{{ $value
    }} '
  summary: 监控tomcat活动线程占总线程的比例
```
## 4. 启动Prometheus使配置生效
```
./prometheus --config.file=prometheus.yml
```

## 5. 查看告警规则配置
 访问：**http://ip:port:9090/rules**