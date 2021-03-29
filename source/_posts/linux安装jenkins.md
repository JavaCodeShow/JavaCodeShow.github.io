---
typora-root-url: ..\assets\img
---

# linux安装jenkins

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



1. 下载jenkins的rpm包

   这是目前最新 jenkins LTS版本，在[清华大学镜像站](https://mirrors.tuna.tsinghua.edu.cn/jenkins/redhat-stable/)  这个里面下载最新版的jenkins。

   mkdir /usr/java/jenkins

   然后上传到linux服务器。

   ```
   [root@iZuf6j6c7vo33inl2830e3Z jenkins]# pwd
   /usr/java/jenkins
   [root@iZuf6j6c7vo33inl2830e3Z jenkins]# ls
   jenkins-2.222.3-1.1.noarch.rpm
   [root@iZuf6j6c7vo33inl2830e3Z jenkins]# 
   ```

2. 安装

   ```
   sudo yum install jenkins-2.222.3-1.1.noarch.rpm
   ```

3. 修改端口

   jenkins 默认8080端口，建议修改一下。以免和tomcat的默认端口号冲突。

   ```
   vim /etc/sysconfig/jenkins
   ```

   可以看到  JENKINS_PORT="8080"， 这里改为   JENKINS_PORT="8091"

   

4. 修改默认镜像源

   ```
   vim /var/lib/jenkins/hudson.model.UpdateCenter.xml 
   ```

   将 url 修改为 清华大学官方镜像：https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

   ```
   <?xml version='1.1' encoding='UTF-8'?>
   <sites>
     <site>
       <id>default</id>
       <url>https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json</url>
     </site>
   </sites>
   ```

5. 启动jenkins

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

   

6. 查看jenkins启动成功

   ```
   ps -ef | grep jenkins
   ```

   

7. 访问jenkins

   http://公网ip地址:端口号

   我本人的是：http://139.224.103.236:8091

   

8. 选择“Install suggested plugins”安装默认的插件，（勾选左边的）下面Jenkins就会自己去下载相关的插件进行安装

9. 设置一下默认管理员的用户名和密码。这里就进入到jenkins的网页了。

10. 系统配置

10. 全局工具配置
    
在这里配置jdk,git，maven的位置
    
12. 接下来可以新建一个任务执行了。

    