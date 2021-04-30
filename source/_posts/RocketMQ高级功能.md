---
author: 江峰
title: "RocketMQ高级功能"
date: 2021-04-30 16:51
comments: true
categories: RocketMQ
summary: RocketMQ高级功能
tags: 
	- RocketMQ
---

# RocketMQ高级功能



## 1. 刷盘机制





## 2. 高可用机制





## 3. 负载均衡机制





## 4. 消息重试

```java
@Slf4j
@Component
@RocketMQMessageListener(topic = "CSS", selectorExpression = "ORDER_CANCEL", consumerGroup = "springboot-mq-consumer-1")
public class TestConsumer implements RocketMQListener<String> {

	@Override
	public void onMessage(String message) {
		log.info("Receive message：" + message);
		throw new ServiceException("200", "消息消费失败");
	}
}
```



消费者如果消费某个消息失败，比如上面示例中的消费者，消费消息失败，则会重试消费消息。

#### 1）重试次数

消息队列 RocketMQ 默认允许每条消息最多重试 16 次，每次重试的间隔时间如下：

| 第几次重试 | 与上次重试的间隔时间 | 第几次重试 | 与上次重试的间隔时间 |
| :--------: | :------------------: | :--------: | :------------------: |
|     1      |        10 秒         |     9      |        7 分钟        |
|     2      |        30 秒         |     10     |        8 分钟        |
|     3      |        1 分钟        |     11     |        9 分钟        |
|     4      |        2 分钟        |     12     |       10 分钟        |
|     5      |        3 分钟        |     13     |       20 分钟        |
|     6      |        4 分钟        |     14     |       30 分钟        |
|     7      |        5 分钟        |     15     |        1 小时        |
|     8      |        6 分钟        |     16     |        2 小时        |

如果消息重试 16 次后仍然失败，消息将不再投递。如果严格按照上述重试时间间隔计算，某条消息在一直消费失败的前提下，将会在接下来的 4 小时 46 分钟之内进行 16 次重试，超过这个时间范围消息将不再重试投递。

**注意：** 一条消息无论重试多少次，这些重试消息的 Message ID 不会改变。





## 5. 死信队列

 



## 6. 消费幂等





## 7. 总结

