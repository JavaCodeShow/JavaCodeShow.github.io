---
author: 江峰
title: "java服务线上问题排查"
date: 2022-11-15 22:15
comments: true
categories: 线上问题排查
summary: 对处理java服务线上问题的常用排查技巧进行整理，方便后续处理线上问题。
tags: 
	- 线上问题排查
---

<meta name="referrer" content="no-referrer" />

# java服务线上问题排查

## 1、内存

### 1.1、 查看服务占用内存

1. 可以通过prometheus查看，此处不做过多说明。

2. 通过arthas的memory命令查看

   ```
   $ memory
   ```

   显示如下：

   ```
   Memory                           used      total      max        usage
   heap                             32M       256M       4096M      0.79%
   g1_eden_space                    11M       68M        -1         16.18%
   g1_old_gen                       17M       184M       4096M      0.43%
   g1_survivor_space                4M        4M         -1         100.00%
   nonheap                          35M       39M        -1         89.55%
   codeheap_'non-nmethods'          1M        2M         5M         20.53%
   metaspace                        26M       27M        -1         96.88%
   codeheap_'profiled_nmethods'     4M        4M         117M       3.57%
   compressed_class_space           2M        3M         1024M      0.29%
   codeheap_'non-profiled_nmethods' 685K      2496K      120032K    0.57%
   mapped                           0K        0K         -          0.00%
   direct                           48M       48M        -          100.00%
   
   ```

3. 直接使用linux自带的命令查看

   ```
   top -o %MEM -b -n 1 | grep java | awk '{print "PID: "$1" \t 虚拟内存: "$5 / 1024"M \t 物理内存(实际占用内存): "$6 / 1024"M \t 共享内存: "$7 / 1024"M \t CPU使用率: "$9"% \t 内存使用率: "$10"%"}'
   ```

   显示如下：

   ```
   [root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# top -o %MEM -b -n 1 | grep java | awk '{print "PID: "$1" \t 虚拟内存: "$5 / 1024"M \t 物理内存: "$6 / 1024"M \t 共享内存: "$7 / 1024"M \t CPU使用率: "$9"% \t 内存使用率: "$10"%"}'
   PID: 12959       虚拟内存: 2123.05M      物理内存: 329.488M      共享内存: 7.28125M      CPU使用率: 0.0%         内存使用率: 17.9%
   PID: 10799       虚拟内存: 2110.75M      物理内存: 194.641M      共享内存: 13.418M       CPU使用率: 0.0%         内存使用率: 10.6%
   PID: 28249       虚拟内存: 2508.25M      物理内存: 194.316M      共享内存: 6.32031M      CPU使用率: 0.0%         内存使用率: 10.6%
   PID: 25613       虚拟内存: 2331.65M      物理内存: 169.684M      共享内存: 5.15625M      CPU使用率: 0.0%         内存使用率: 9.2%
   [root@iZuf6j6c7vo33inl2830e3Z spring-application-jar]# 	
   ```

### 1.2、服务OOM如何排查

#### 1.2.1、获取dump文件

1. 主动导出dump文件

   1. 获取进程的PID

      ```
      ps -ef|grep java
      jps -l
      ```

   2. 根据pid，下载dump文件到当前路径，导出整个JVM 中内存信息

      格式：

      jmap -dump:format=b,file=文件名 [pid]
      
      jmap -dump:live,format=b,file=文件名 [pid]            只dump存活的对象，存活的对象是GC之后没有被回收的对象
      
      ```
      jmap -dump:format=b,file=/usr/java/dump/heapdump.hprof 32756
      
      jmap -dump:live,format=b,file=/usr/java/dump/heapdump.hprof 32756
      ```

#### 1.2.2、OOM时导出dump文件

1. 我们可以添加 **-XX:+HeapDumpOnOutOfMemoryError** 参数开启“**当堆内存空间溢出时输出堆的内存快照**”功能，而 **-XX:HeapDumpPath** 参数则指定生成的堆转储存放位置，可以不填路径，只填文件名，说明是当前目录。

   ```
   #指定dump文件存放位置
   -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/java/dump/
   
   #在当前服务的的根目录下面存放dump文件
   -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=testDump.hprof
   ```

#### 1.2.3、分析dump文件

1. 如果是 **Windows** 系统我们也可以直接使用JDK自带的 **jvisualvm** 工具（在 **JDK** 的 **bin** 目录下：jvisualvm.exe）

   目录位置：%JAVA_HOME%\bin,如果不确定JAVA_HOME的位置，可以在cmd命令行中输入：echo %JAVA_HOME%  确定位置

   > 如果出现内存不足，可以将%JAVA_HOME%\lib\visualvm\etc目录里面的visualvm.conf的堆内存修改一下。
   >
   > ```
   > -Xms4096m -J-Xmx4096m
   > visualvm_default_options="-J-client -J-Xms4096m -J-Xmx4096m ***
   > ```

   或者在网页上下载最新版的visualvm：https://visualvm.github.io/，如果使用时内存不足也是去刚下载的visualvm的etc目录下修改visualvm.conf文件。**visualvm建议安装创建插件：Visual GC以及Startup Profiler**

   ![图片描述](https://img-blog.csdnimg.cn/53a7e17be93749cfa780ed8b1614ebab.png#pic_center)

2. 从下面图片里面可以UserDTO这个对象占用了78.1%的内存，实例数是8720756个，而其他的对象占用内存并不大，那么罪魁祸首就是这个UserDTO对象，我们点击进去继续查看。

   ![图片描述](https://img-blog.csdnimg.cn/0bdc2a2f34ad461bbc6f581f4899a92b.png#pic_center)

3. 分析对象

   从下面图片可以看到左边是这个UserDTO对象的所有实例，右上是对象的具体信息，包含对象里面的字段，右下是这个对象的被引用信息，在这个图里面也可以看到这个对象有8720756个，查看引用看到这个对象是在一个List里面，我们点击这个list继续往下看。

   ![图片描述](https://img-blog.csdnimg.cn/9992d046bf414e4aa18ddbdb83a59c94.png#pic_center)

4. 点开这个list会发现，这个list的大小是8720756万个，这个list的泛型是UserDTO对象，那么这个list中有8720756万个UsetDTO对象，那么OOM的原因也就水落石出了。从引用中可以看到这个list对象是在HelloService这个类里面，那么接下来结合代码不难发现是哪一处的代码出现问题，然后去改就ok了。

   ![图片描述](https://img-blog.csdnimg.cn/7b86abe6a783434b82c233b9b9645df1.png#pic_center)



5. 查看这个对象在哪个地方被引用了，以及GC Root链

   ![图片](https://img-blog.csdnimg.cn/36703789a65c42968d41fb4661d71503.png#pic_center)

6. 查看对象当前的线程堆栈信息

   ![图片](https://img-blog.csdnimg.cn/a3f83d6b1b6e4b529be5e9edbff3b92c.png#pic_center)

   ![图片](https://img-blog.csdnimg.cn/dda0c81faf374dfd92523be61b6d013d.png#pic_center)

这样子具体有问题的代码位置就找到了。

## 2、CPU

### 2.1、查看系统CPU

linux服务器里面输入top命令，显示如下：

```
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND   
20571 root      20   0 2756184 296280  15236 S  80.4  7.8   0:36.48 java
  386 root      20   0   39108   5956   5628 S   6.2  0.2   0:33.12 systemd-journal 
11133 root      20   0  162104   2292   1616 R   6.2  0.1   0:00.14 top
    1 root      20   0   51916   3640   2156 S   0.0  0.1   0:51.89 systemd
    2 root      20   0       0      0      0 S   0.0  0.0   0:00.17 kthreadd
    4 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/0:0H         
```

可以看到PID为20571的这个进程占用了80.4%的CPU。那么接下来就是分析这个java服务的cpu为什么这么高了。

### 2.2、分析服务CPU过高

1. 安装arthas，选择PID对应的服务。

2. 通过thread -n 3 就能找到消耗cpu最高的三个线程的执行情况。这里只贴出了消耗cpu最高的的线程。

   ```
   [arthas@3492]$ thread -n 3
   thread -n 3
   "main" Id=1 cpuUsage=89.35% deltaTime=187ms time=155281ms RUNNABLE
       at java.io.FileOutputStream.writeBytes(Native Method)
       at java.io.FileOutputStream.write(FileOutputStream.java:326)
       at java.io.BufferedOutputStream.flushBuffer(BufferedOutputStream.java:82)
       at java.io.BufferedOutputStream.flush(BufferedOutputStream.java:140)
       at java.io.PrintStream.write(PrintStream.java:482)
       at sun.nio.cs.StreamEncoder.writeBytes(StreamEncoder.java:221)
       at sun.nio.cs.StreamEncoder.implFlushBuffer(StreamEncoder.java:291)
       at sun.nio.cs.StreamEncoder.flushBuffer(StreamEncoder.java:104)
       at java.io.OutputStreamWriter.flushBuffer(OutputStreamWriter.java:185)
       at java.io.PrintStream.write(PrintStream.java:527)
       at java.io.PrintStream.print(PrintStream.java:669)
       at java.io.PrintStream.println(PrintStream.java:806)
       at com.jf.HelloService.hello(HelloService.java:7)
   
   ```

3. 从线程堆栈信息看到HelloService中hello方法导致的，代码位置是第7行。知道了代码的位置，接下来去分析就不难了。至此cpu的过高的原因也就水落石出了。 
