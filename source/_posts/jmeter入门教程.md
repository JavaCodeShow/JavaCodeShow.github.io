---
author: 江峰
title: "jmeter入门教程"
date: 2020-05-12 22:15
comments: true
categories: 压测
summary: jmeter入门教程
tags: 
	- jmeter

---



# jmeter入门教程

1. 下载jmeter

   官网：https://jmeter.apache.org/

2. 解压Jmeter包（解压后即可使用）

3. 修改jmeter的语言为中文（默认为英文）

   1. 打开jmeter的bin目录下面的jmeter.properties

   2. 修改language=zh_CN，记得把注释放开。修改后如下图所示：

      ![](https://img-blog.csdnimg.cn/c7e2e13c6c1149ffbdde09ede939914b.png)

4. 双击解压后的文件夹bin目录下的Jmeter.bat启动Jmeter

   ![](https://img-blog.csdnimg.cn/6a719791901e437590603276a6cedfb7.png#pic_center)

5. 创建线程组

   ![](https://img-blog.csdnimg.cn/4380a774fbf3434c882fdb52761a6a4e.png#pic_center)



5. 设置线程参数：开启10个线程，同时启动，每个线程重复一次

   ![](https://img-blog.csdnimg.cn/ed9ae8dac6a84651b340353c22a3e413.png#pic_center)

6. 添加http请求

   ![](https://img-blog.csdnimg.cn/a2f0e74ab3434f17b44fc1ebba739e13.png#pic_center)

7. 发起get请求

   ![](https://img-blog.csdnimg.cn/165e4d0459984b65872369baa1221a6f.png#pic_center)

8. 发起post请求

   ![](https://img-blog.csdnimg.cn/656f2ec789af4612861a48217a1a78d5.png#pic_center)

注意：post请求需要设置content-type

![](https://img-blog.csdnimg.cn/d3e49a6bd7e14893a5f38d438bb8ff48.png#pic_center)

![](https://img-blog.csdnimg.cn/62028f9ed2f2439bb1c8d873a39a3d5f.png#pic_center)

9. 查看请求结果

   ![](https://img-blog.csdnimg.cn/694cb95c84e646d8b0888b27202fc59a.png#pic_center)

10. JMeter聚合报告（Aggregate Report）理解：https://blog.csdn.net/lion19930924/article/details/51189218
