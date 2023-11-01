---
author: 江峰
title: "使用rocketmq-spring-boot-starter发送，消费消息的简单示例"
date: 2021-04-02 16:51
comments: true
categories: RocketMQ
summary: 使用rocketmq-spring-boot-starter发送，消费消息的简单示例
tags: 
	- RocketMQ
---

<meta name="referrer" content="no-referrer" />

# 使用rocketmq-spring-boot-starter发送，消费消息的简单示例



## 1. 引入依赖

```java
<!-- rokcetmq starter  -->
<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-spring-boot-starter</artifactId>
    <version>2.2.0</version>
</dependency>
```



## 2. 修改配置文件

```java
# application.properties
rocketmq.name-server=139.224.103.236:9876
rocketmq.producer.group=spring-application-name
```



## 3. 生产者发送消息

```java
// 引入rocketMQTemplate
@Autowired
private RocketMQTemplate rocketMQTemplate;

// 通过rocketMQTemplate发送消息。
// destination: formats: `topicName:tags`
// payload: 消息内容
rocketMQTemplate.syncSend("CSS:ORDER_CANCEL", "orderId-111");
```



## 4. 消费者接受消息

消费的的依赖和配置文件同生产者一样。组名修改即可。

```java
@Slf4j
@Component
@RocketMQMessageListener(topic = "CSS", selectorExpression = "ORDER_CANCEL", consumerGroup = "spring-application-name")
public class TestConsumer implements RocketMQListener<String> {

	@Override
	public void onMessage(String message) {
		log.info("Receive message：" + message);
        // 业务逻辑处理。。。
	}
}
```



## 5. 总结

本文对Spring项目里面对RocketMQ发送消息和消费消息，进行了简单的示例说明。方便大家入门使用！

实际项目中。有能力的公司一般都会对RocketMQ进行二次封装，将RocketMQ的用法化繁为简。

后面会陆续介绍RocketMQ的高级用法。