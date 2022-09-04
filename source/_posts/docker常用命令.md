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

## 基本命令

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

    1. 删除没有运行的容器
    
       ```
       docker rm 容器name/容器id
       ```
    
    2. 强制删除正在运行的容器
    
       ```
       docker rm -f 容器name/容器id
       ```

11. docker里面安装vim

    ```
    1. apt-get update
    2. apt-get install vim
    ```

12.  docker修改容器开机自启

    ```
    docker update 容器id/名字 --restart=always
    ```

13. 进入容器内部

    ```
    docker exec -it 容器id/名字 bash
    ```

14. 挂载卷到外部修改

    修改页面只需要去 主机的 /data/html

    -v 这个给命令就是将外部的目录和容器内部的目录映射起来

    ```
    docker run --name=mynginx   \
    -d  --restart=always \
    -p  88:80 -v /data/html:/usr/share/nginx/html:ro  \
    nginx
    ```

15. 复制文件

    把容器指定位置的东西复制出来

    ```
     docker cp 5eff66eec7e1:/etc/nginx/nginx.conf  /data/conf/nginx.conf
    ```

    把外面的内容复制到容器里面

    ```
    docker cp  /data/conf/nginx.conf  5eff66eec7e1:/etc/nginx/nginx.conf
    ```

    

## 打包为新的镜像

1. 提交改变：将修改后的容器打包成新的镜像，之后可以直接启动新的镜像。

   ```
   docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]
   
   docker commit -a "jiangfeng"  -m "首页变化" 容器id/容器名字 mynginx:1.0
   
   ```

2. 镜像传输

   ```
   # 将自己创建的镜像保存成压缩包
   docker save -o abc.tar mynginx:1.0
   
   # 别的机器加载这个镜像
   docker load -i abc.tar
   ```

   

## 推送远程仓库

1. 基本命令

   ```
   docker tag local-image:tagname new-repo:tagname
   docker push new-repo:tagname
   ```

2. 把旧镜像的名字，改成仓库要求的新版名字

   ```
   docker tag mynginx:1.0 1500041584/mynginx:1.0
   ```

3. 登录以及推出docker hub

   ```
   docker login 
   ```

   ```
   docker logout
   ```

4. 推动到docket hub 私人仓库

   ```
   docker push 1500041584/mynginx:1.0
   ```

5. 下载新的镜像

   ```
   docker pull 1500041584/mynginx:1.0
   ```

