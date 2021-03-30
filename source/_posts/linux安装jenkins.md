---
typora-root-url: linux安装jenkins
---

# linux安装jenkins

## 一、安装jdk和maven

首先在安装jenkins之前。需要先安装jdk 和 maven。至于 jdk 和 maven 和安装教程，这里就不说了。

**查看jdk安装成功**：java -version

显示下面的信息说明安装成功

```
[root@iZuf6j6c7vo33inl2830e3Z ~]# java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
[root@iZuf6j6c7vo33inl2830e3Z ~]# 
```



**查看maven安装成功**：mvn -v

显示下面的信息说明安装成功

```
[root@iZuf6j6c7vo33inl2830e3Z ~]# mvn -v
Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)
Maven home: /usr/java/apache-maven-3.6.3
Java version: 1.8.0_131, vendor: Oracle Corporation, runtime: /usr/java/jdk1.8/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-1160.11.1.el7.x86_64", arch: "amd64", family: "unix"
[root@iZuf6j6c7vo33inl2830e3Z ~]# 
```

在进行下面的操作之前，请确保这两个安装完毕。

## 二、安装git

### 2.1 安装git命令

```
yum install git

```

### 2.2 查看git是否安装成功

```
[root@iZuf6j6c7vo33inl2830e3Z ~]# git version
git version 1.8.3.1
```

### 2.3 配置全局的用户名和密码

```
git config --global user.name "admin"
git config --global user.email "admin@abc.com"
```

### 2.4 生成授权证书

中间直接全部回车就行

```
ssh-keygen -t rsa -C "admin@abc.com"
```

### 2.5 github ssh配置

复制/root/.ssh/id_rsa.pub里的内容，到github进行配置ssh公钥



## 三、在linux服务器里面安装jenkins

### 3.1 下载jenkins的rpm包

这是目前最新 jenkins LTS版本，在[清华大学镜像站](https://mirrors.tuna.tsinghua.edu.cnredhat-stable/)  这个里面下载最新版的jenkins。

mkdir /usr/java/jenkins

然后上传到linux服务器。

```
[root@iZuf6j6c7vo33inl2830e3Z jenkins]# pwd
/usr/java/jenkins
[root@iZuf6j6c7vo33inl2830e3Z jenkins]# ls
jenkins-2.222.3-1.1.noarch.rpm
[root@iZuf6j6c7vo33inl2830e3Z jenkins]# 
```

### 3.2 安装

```
sudo yum install jenkins-2.222.3-1.1.noarch.rpm
```

### 3.3 修改端口

jenkins 默认8080端口，建议修改一下。以免和tomcat的默认端口号冲突。

```
vim /etc/sysconfig/jenkins
```

可以看到  JENKINS_PORT="8080"， 这里改为   JENKINS_PORT="8091"

### 3.4 修改默认镜像源

```
vim /var/libhudson.model.UpdateCenter.xml 
```

将 url 修改为 清华大学官方镜像：https://mirrors.tuna.tsinghua.edu.cnupdates/update-center.json

```
<?xml version='1.1' encoding='UTF-8'?>
<sites>
  <site>
    <id>default</id>
    <url>https://mirrors.tuna.tsinghua.edu.cnupdates/update-center.json</url>
  </site>
</sites>
```

### 3.5 启动jenkins

```
启动jenkins：service jenkins start
关闭jenkins：service jenkins stop
重启jenkins：service jenkins restart

```

这里因为没有修改jdk的地址，会启动失败

```
[root@iZuf6j6c7vo33inl2830e3Z jenkins]# systemctl start jenkins.service
Job for jenkins.service failed because the control process exited with error code. See "systemctl status jenkins.service" and "journalctl -xe" for details.
[root@iZuf6j6c7vo33inl2830e3Z jenkins]# 
```

查看失败原因

```
systemctl status jenkins.service
```

```

[root@iZuf6j6c7vo33inl2830e3Z jenkins]# systemctl status jenkins.service
● jenkins.service - LSB: Jenkins Automation Server
   Loaded: loaded (/etc/rc.d/init.d/jenkins; bad; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2021-03-29 15:07:28 CST; 19s ago
     Docs: man:systemd-sysv-generator(8)
  Process: 18344 ExecStart=/etc/rc.d/init.d/jenkins start (code=exited, status=1/FAILURE)

Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z systemd[1]: Starting LSB: Jenkins Automation Server...
Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z runuser[18351]: pam_unix(runuser:session): session opened for user jenkins by (uid=0)
Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z jenkins[18344]: Starting Jenkins bash: /usr/bin/java: No such file or directory
Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z systemd[1]: jenkins.service: control process exited, code=exited status=1
Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z jenkins[18344]: [FAILED]
Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z systemd[1]: Failed to start LSB: Jenkins Automation Server.
Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z systemd[1]: Unit jenkins.service entered failed state.
Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z systemd[1]: jenkins.service failed.

```



从这一行：Mar 29 15:07:28 iZuf6j6c7vo33inl2830e3Z jenkins[18344]: Starting Jenkins bash: /usr/bin/java: No such file or directory

可以看到是没有修改jdk的地址导致的。 

如果忘了jdk的地址可以通过    which java  这个命令查看

修改jenkins里面jdk的地址：

```
vim /etc/init.d/jenkins
```

在这个文件里面找到修改jdk地址的地方，改为自己的jdk地址就好了。然后重新启动

### 3.6 查看jenkins启动成功

```
ps -ef | grep jenkins
```

### 3.7 访问jenkins

http://公网ip地址:端口号

我本人的是：http://139.224.103.236:8091

## 三、jenkins初始化配置

![Snipaste_2021-03-29_21-49-44](Snipaste_2021-03-29_21-49-44.png)

输入下面的命令，即可获取密码

```undefined
cat /root/.jenkins/secrets/initialAdminPassword  
```



安装插件，直接安装默认提供的插件即可。

![](6907580-d2ae24d404f8d137.png)



创建管理员账号

![6907580-ce4cf9c7eb5b435f](6907580-ce4cf9c7eb5b435f.png)



## 四、jenkins基本配置

> 开发人员将工作区的代码提交到代码库（svn或者git），代码库再调用钩子程序通知Jenkins（我已经更新了代码，你也要重新部署一版了），钩子程序是我们自己编写，这个钩子程序很容易后续会提到怎么编写钩子程序
> Jenkins收到代码库的提醒之后立马去代码库里获取最新的源码，再通过调用maven插件将源码打包成jar，再通过Publish over SSH插件将jar包传到一台或者多台服务器上，再调用服务器的脚本启动jar包，这就是Jenkins工作的整体流程。

### 4.1 插件安装

**安装Publish over SSH插件并配置**

系统管理==》插件管理

搜索Publish over SSH下载安装成功后后重新登陆jenkins



![Snipaste_2021-03-29_21-56-23](Snipaste_2021-03-29_21-56-23.png)

![Snipaste_2021-03-29_21-56-23](Snipaste_2021-03-29_21-56-23.png)

​		

### 4.2 系统配置

**系统配置里面有一些实用的功能可以进行配置。需要的话可以自行配置。**

拉到最后面找到Publish over SSH，点击新增



![20200524113201698](20200524113201698.png)



![20200524113301937](20200524113301937.png)



​	name：随便填
​	Hostname：服务器IP（这个就是要把打包好的jar包发送并运行的目标主机）
​	Username：root
​	Remote Directory：要发送到的远程主机的目录，这里我们填 / 根目录就行，因为后面这个路径我们还要配置

​	填好之后在点击高级配置密码和端口

![Snipaste_2021-03-29_23-38-06](Snipaste_2021-03-29_23-38-06.png)





![Snipaste_2021-03-29_23-39-26](Snipaste_2021-03-29_23-39-26.png)

​	测试一下，能连接上即可。

###  4.3 全局工具配置

在这里配置jdk，git，maven的位置

**maven配置**

![Snipaste_2021-03-29_22-03-22](Snipaste_2021-03-29_22-03-22.png)

​		**JDK安装**



![Snipaste_2021-03-29_22-04-56](Snipaste_2021-03-29_22-04-56.png)

​	**git安装**



![Snipaste_2021-03-29_22-05-59](Snipaste_2021-03-29_22-05-59.png)



​	**maven安装**



![Snipaste_2021-03-29_22-06-54](Snipaste_2021-03-29_22-06-54.png)



### 4.4 节点配置

在Jenkins中依次点击：系统管理 -> 节点管理 -> 新建节点



![20191019135659465](20191019135659465.png)

保存后，点击启动代理配置，查看日志是否成功



## 五、构建maven项目

1. 接下来可以新建一个任务执行了。





![Snipaste_2021-03-30_00-03-14](Snipaste_2021-03-30_00-03-14.png)

1. 

   

7. shell脚本配置

8. Waiting for Jenkins to finish collecting data 这一步怎么删掉  。不然编译完之后一直等待一段时间

   



同级目录：start.sh
