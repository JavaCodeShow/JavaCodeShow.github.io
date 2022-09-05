---
author: 江峰
title: "arthas常用命令记录"
date: 2022-09-05 22:15
comments: true
categories: arthas
summary: arthas常用命令记录
tags: 
	- arthas
---

# arthas常用命令记录.md

## 下载arthas

```
curl -O https://arthas.aliyun.com/arthas-boot.jar
```

## 启动arthas

```
java -jar arthas-boot.jar
```

## 基本命令

1. **arthas后台异步任务**

   1. arthas使用&在后台异步执行任务

      ```
      trace Test t &
      ```

   2. 通过jobs查看后台异步任务

      ```
      jobs
      ```

2. **dashboard：查看当前系统的实时数据面板**

   ```text
   dashboard
   ```

3. **memory：查看 JVM 内存信息。**

   ```
   memory
   ```

4. **sysenv查看当前JVM的环境属性（System Environment Variables），支持通过`TAB`键自动补全**

   ```
   sysenv
   ```

5. **sysprop查看当前 JVM 的系统属性(System Property)，支持通过`TAB`键自动补全**

   **此命令可以查看配置文件的信息**

   ```
   sysprop
   ```

6. **thread：查看当前线程信息，查看线程的堆栈**

   1. 查看当前最忙的前 N 个线程并打印堆栈

      ```
      thread -n 3
      ```

   2. thread id, 显示指定线程的运行堆栈

      ```
      thread 1
      ```

   3. thread -b, 找出当前阻塞其他线程的线程

      ```
      thread -b
      ```

7. **jad：反编译指定已加载类的源码**

   ```
   jad --source-only java.lang.String
   ```

8. **monitor：方法执行监控**

   ```
   monitor com.jf.redisstudy.controller.HelloController getName  -n 10  --cycle 10 &
   ```

9. **stack：输出当前方法被调用的调用路径**

   ```
   stack com.jf.redisstudy.controller.HelloController hello  -n 5 
   ```

10. **trace：方法内部调用路径，并输出方法路径上的每个节点上耗时**

    ```
    trace com.jf.redisstudy.controller.HelloController hello  -n 5 --skipJDKMethod false &
    ```

11. **tt：方法执行数据的时空隧道，记录下指定方法每次调用的入参和返回信息，并能对这些不同的时间下调用进行观测**

    tt命令可以用在类上，也可以用在方法上

    用法方法上：

    ```
    tt -t com.jf.redisstudy.controller.HelloController hello -n 5 &
    ```

    当你用 tt 记录了一大片的时间片段之后，你希望能从中筛选出自己需要的时间片段，这个时候你就需要对现有记录进行检索。

    ```
    tt -l
    ```

    查看调用信息

    ```
    tt -i 索引id
    ```

    重做一次调用

    ```
    tt -i 索引id -p
    ```

12. **watch：方法执行出入参查看**

    ```
    watch com.jf.redisstudy.controller.HelloController hello '{params,returnObj,throwExp}'  -n 5  -x 3 &
    ```

13. **json格式查看结果**

    ```
    options json-format true
    ```

    