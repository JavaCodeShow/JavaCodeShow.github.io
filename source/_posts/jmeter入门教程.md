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

3. 可修改语言为中文

   ![图片描述](https://img-blog.csdnimg.cn/c9ea2f2fae0e4806bebfdc3e7ecad347.png)

4. 双击解压后的文件夹bin目录下的Jmeter.bat启动Jmeter

   ![图片描述](https://img-blog.csdnimg.cn/6a719791901e437590603276a6cedfb7.png#pic_center)

5. 创建线程组

   ![图片描述](https://img-blog.csdnimg.cn/4380a774fbf3434c882fdb52761a6a4e.png)

6. 设置线程参数：开启10个线程，同时启动，每个线程重复一次

   ![图片描述](https://img-blog.csdnimg.cn/ed9ae8dac6a84651b340353c22a3e413.png)

7. 添加http请求

   ![图片描述](https://img-blog.csdnimg.cn/a2f0e74ab3434f17b44fc1ebba739e13.png)

8. 发起get请求

   ![图片描述](https://img-blog.csdnimg.cn/165e4d0459984b65872369baa1221a6f.png)

9. 发起post请求

   ![图片描述](https://img-blog.csdnimg.cn/656f2ec789af4612861a48217a1a78d5.png)

   ​	注意：post请求需要设置content-type

   ![图片描述](https://img-blog.csdnimg.cn/d3e49a6bd7e14893a5f38d438bb8ff48.png)

   ![图片描述](https://img-blog.csdnimg.cn/62028f9ed2f2439bb1c8d873a39a3d5f.png)

10. 可以导入CURL

   ![图片描述](https://img-blog.csdnimg.cn/e0135ad476f64f8e91c4d5526755b755.png)

   ![图片描述](https://img-blog.csdnimg.cn/0574069ddab74ebca284cd2785ea28a3.png)

**注意：这里需要把Add cookie header to Cookie Manager 勾上**

10. 查看请求结果

![图片描述](https://img-blog.csdnimg.cn/694cb95c84e646d8b0888b27202fc59a.png#pic_center)
