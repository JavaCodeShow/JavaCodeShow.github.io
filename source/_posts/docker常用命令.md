---
author: 江峰
title: "docker常用命令"
date: 2020-05-12 22:15
comments: true
categories: docker
summary: 对docker的常用命令进行整理，方便后续使用。
tags: 
	- docker
---

# docker常用命令

1. 搜索镜像

   ```
   docker search xxx
   ```

2. 下载镜像

   ```
   docker pull xxx
   ```

3. 查看镜像 

   查看所有镜像

   ```
   docker images
   ```

    查看指定镜像

   ```
   docker images | grep 容器名字
   ```

4. 删除镜像

   ```
   docker rmi  镜像name/镜像id(会提示先停止使用中的容器) 
   ```

5. 查看所有容器

   ```
    docker ps -a
   ```

6. 查看容器运行日志

   ```
    docker logs 容器名称/容器id
   ```

7. 停止容器运行

   ```
   docker stop 容器name/容器id
   ```

8. 终止容器后运行

   ```
   docker start 容器name/容器id
   ```

9. 容器重启

   ```
    docker restart 容器name/容器id
   ```

10. 删除容器

    ```
     docker rm 容器name/容器id
    ```

11. docker里面安装vim

    ```
    1. apt-get update
    2. apt-get install vim
    ```

    

    



 

