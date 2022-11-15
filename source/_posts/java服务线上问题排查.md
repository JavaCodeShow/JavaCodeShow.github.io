---
author: 江峰
title: "java服务线上问题排查"
date: 2022-11-15 22:15
comments: true
categories: 问题排查
summary: 对处理java服务线上问题的常用排查技巧进行整理，方便后续处理线上问题。
tags: 
	- 问题排查
---

# java服务线上问题排查

## 一、查看服务占用内存

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

## 二、服务OOM如何排查

### 	1. 获取dump文件

1. 主动导出dump文件

   1. 获取进程的PID

      ```
      ps -ef|grep java
      jps -l
      ```

   2. 根据pid，下载dump文件到当前路径，导出整个JVM 中内存信息

      格式：jmap -dump:format=b,file=文件名 [pid]

      ```
      jmap -dump:format=b,file=/usr/local/dump/heapdump.hprof 14709
      ```

2. 发生OOM时导出dump文件

   1. 我们可以添加 **-XX:+HeapDumpOnOutOfMemoryError** 参数开启“**当堆内存空间溢出时输出堆的内存快照**”功能，而 **-XX:HeapDumpPath** 参数则指定生成的堆转储存放位置。

      ```
      -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/local/dump/
      ```

1. 分析dump文件

   1. 如果是 **Windows** 系统我们也可以直接使用JDK自带的 **jvisualvm** 工具（在 **JDK** 的 **bin** 目录下：jvisualvm.exe）

      ![](https://cdn.nlark.com/yuque/0/2022/png/32668413/1668525503344-cff5c1d2-6e45-47a8-be43-586ca9cde4f0.png)

   2. 从下面图片里面可以UserDTO这个对象占用了74.9%的内存，实例数是1000万个，点击进去进行查看。

      

​			![](https://cdn.nlark.com/yuque/0/2022/png/32668413/1668526684395-9ac083c1-5c78-4e37-a36c-6f2e8e7b1b92.png)

3. 如果出现内存不足，可以将%JAVA_HOME%\lib\visualvm\etc目录里面的visualvm.conf的堆内存修改一下。

   ```
   -Xms1024m -J-Xmx4096m
   ```

4. 分析对象

   从下面图片可以看到左边是这个UserDTO对象的所有实例，点击一个实例后可以看到这个对象里面的字段以及这个对象是在一个List里面，是一个list里面的元素。

   ![](https://cdn.nlark.com/yuque/0/2022/png/32668413/1668526318516-c04d6b69-7964-4caf-8824-dc1043ba8a0e.png)

   

​		点开这个list会发现，这个list的大小是1000万个，所以这个list中有1000万个UsetDTO对象，那么OOM的原因也就水落石出了。而从引用中可以看到这个list对象是在HelloController这个类里面，那么接下来结合代码去改就ok了。

![](https://cdn.nlark.com/yuque/0/2022/png/32668413/1668526550174-f2019dc3-88c2-4d52-97b1-b0ebb6a6693e.png)





## CPU
