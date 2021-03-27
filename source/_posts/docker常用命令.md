---
author: 江峰
title: "docker常用命令"
date: 2020-05-012 22:15
comments: true
categories: docker
summary: 对docker的常用命令进行整理，方便后续使用。
tags: 
	- docker
---

# docker常用命令

## 搜索镜像

docker search xxx

## 下载镜像

docker pull xxx

## 查看镜像 

1. 查看所有镜像：docker images

2. 查看指定镜像：docker images | grep redis

## 删除镜像

docker rmi  镜像name/镜像id(会提示先停止使用中的容器) 

## 查看所有容器

 docker ps -a

## 查看容器运行日志

 docker logs 容器名称/容器id

## 停止容器运行

 docker stop 容器name/容器id

## 终止容器后运行

 docker start 容器name/容器id

## 容器重启

 docker restart 容器name/容器id

## 删除容器

 docker rm 容器name/容器id