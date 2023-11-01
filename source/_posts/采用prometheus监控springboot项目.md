---
author: 江峰
title: "使用prometheus监控SpringBoot项目"
date: 2020-07-01 10:55
comments: true
categories: prometheus
summary: 使用prometheus监控SpringBoot项目。
tags: 
	- prometheus
---

<meta name="referrer" content="no-referrer" />

##  1. springboot项目中配置prometheus


 对于springboot应用，需要以下几个步骤
springboot应用开启endpoint，添加actuator的依赖和promethus的依赖

```
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<dependency>
  <groupId>io.micrometer</groupId>
  <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```
在yml文件或者properties文件中，加入以下配置：

```
# 监控相关配置
# 开启监控
management:
  endpoints:
    web:
      exposure:
        include: "*"  
```
这里需要注意是，"*"号是需要加双引号的。
启动项目：访问：http://ip:port/actuator/prometheus
如果有数据展示说明配置成功。要是项目配置了context-path。需要加上context-path的路径。
项目里面不建议配置context-path

## 2. 下载prometheus
配置prometheus
首先要在官网 [https://prometheus.io/](https://prometheus.io/)
在下载页面，选择何时的版本下载，推荐下载tar.gz包。下载好后，进行解压。在合适的路径下即可。
这里介绍下prometheus的目录和文件：
1、prometheus采用的都是yml文件的配置方式。
2、在根目录下，有个prometheus.yml配置文件，文件初始化的内容如下： 
```
global:
  scrape_interval:     15s   # 这个是每次数据手机的频率
  evaluation_interval: 15s   # 评估告警规则的频率。

rule_files:
  # - "first.rules"
  # - "second.rules"

scrape_configs:               # 通过这里的配置控制prometheus监控的资源
  - job_name: prometheus      # prometheus自身默认的
    static_configs:
      - targets: ['localhost:9090']  # 默认暴露的是9090端口服务
```
global是全局配置。具体见上面的注释说明。

## 3. prometheus配置文件修改
添加我们的应用，对springboot进行监控
```
- job_name: 'spring-sample'
    metrics_path: 'actuator/prometheus'    # 这里我们springboot暴露出来的endpoint
    scrape_interval: 5s                    # 信息收集时间是间隔5秒
    static_configs:
    - targets: ['localhost:8778']          # 这里是springboot暴露出来的地址和端口
```

## 4. 启动prometheus
这些配置完成后，可以启动prometheus，
cd进到prometheus的根目录
**linux中prometheus启动命令**

```
./prometheus --config.file=prometheus.yml
```

**windows中prometheus启动命令**


添加：--web.enable-lifecycle
这种启动方法使Prometheus支持reload 配置文件**
```
prometheus.exe --web.enable-lifecycle
```
**reload地址**
```
http://localhost:9090/-/reload
```

## 5. 配置grafana
下载grafana，直接启动即可。
1. 启动命令参见官网：./grafana-server web
2. 配置datasource，选择prometheus。这个里面有个很重要的注意点，我看网上很多人在转如何用prometheus监控springboot应用，估计自己没去实际搭建，在interval这个时间上，默认是数字，比如15,代表是15秒。在添加dashboard的时候，会发现监控图标左上角是个红点，报错：Invalid interval string, expecting a number followed by one of "Mwdhmsy" ，这个错的解决方案就是在这些时间间隔后面加个"s"。问题解决。
3. 选择dashboard，import的里输入一个模板，可以去dashboards去找你对应的模板，我们这里选用jvm的4701模板，然后就能看到你的springboot的监控信息了。到此，整个搭建完成。