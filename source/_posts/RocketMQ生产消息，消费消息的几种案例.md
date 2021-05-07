---
author: 江峰
title: "RocketMQ生产消息，消费消息的几种案例"
date: 2021-04-01 16:51
comments: true
categories: RocketMQ
summary: 本文对RocketMQ发送消息的几种案例进行了简单的介绍和示例。用来参考和回顾再好不过了。
tags: 
	- RocketMQ
---



## 1. Producer发送消息的三种方式

Producer 发送消息，RocketMQ 提供了三种模式。

- 同步发送
- 异步发送
- OneWay 发送

示例代码如下：

```java
// 1、同步发送
SendResult sendResult = producer.send(msg);

//2、异步发送
producer.send(msg, new SendCallback() {
    @Override
    public void onSuccess(SendResult sendResult) {
    }
    @Override
    public void onException(Throwable e) {
    }
});

//3、 Oneway发送
producer.sendOneway(msg);
```

- **1、同步发送**
   Producer 向 broker 发送消息，阻塞当前线程等待 broker 响应 发送结果。
- **2、异步发送**
   Producer 首先构建一个向 broker 发送消息的任务，把该任务提交给线程池，等执行完该任务时，回调用户自定义的回调函数，执行处理结果。
- **3、Oneway 发送**
   Oneway 方式只负责发送请求，不等待应答，Producer 只负责把请求发出去，而不处理响应结果。



## 2. Consumer消费消息的两种方式

RocketMQ里面有消费者组的概念。

先说下以下两个问题，方面后续的理解。

问题1：一个消费者组里面为什么会有多个消费者？

​	答：当一个服务有几个节点时，便会有多个消费者。而这些消费者里面应该只有一个消费者能够消费消息。

问题2：为什么会有多个消费者组？

​	答：微服务情况下。一个消息可能会被多个业务服务消费。比如商品服务。优惠券服务。这每个服务都是一个消费者组。

### 2.1 集群模式

```java
consumer.setMessageModel(MessageModel.CLUSTERING);
```

在此模式下，当多个消费者在同一个消费者组时，这些消费者里面只会有一个消费者能够消费消息。

也就是说存在多个消费者组时，每个消费者组里面只会有一个消费者能够消费消息。



**故此：消费者组的名字一般是服务的名字。TOPIC的名字一般是哪个服务发出来的，就是哪个服务的名字。**

**一般使用集群模式即可。**



### 2.2 广播模式

```java
consumer.setMessageModel(MessageModel.BROADCASTING);
```

在此模式下。如果多个消费者处于同一个消费者组里面，这个消费者组里面的每个消费者都会消费消息。

## 3. 顺序消息

消息有序指的是可以按照消息的发送顺序来消费(FIFO)。RocketMQ可以严格的保证消息有序，可以分为分区有序或者全局有序。

顺序消费的原理解析，在默认的情况下消息发送会采取Round Robin轮询方式把消息发送到不同的queue(分区队列)；而消费消息的时候从多个queue上拉取消息，这种情况发送和消费是不能保证顺序。但是如果控制发送的顺序消息只依次发送到同一个queue中，消费的时候只从这个queue上依次拉取，则就保证了顺序。当发送和消费参与的queue只有一个，则是全局有序；如果多个queue参与，则为分区有序，即相对每个queue，消息都是有序的。



## 4. 延时消息

发送者代码示例：

```java
Message message = new Message("topic1", "tagA",("Hello scheduled message " + i).getBytes());
message.setDelayTimeLevel(2);
SendResult send = producer.send(message);
```

延时等级：

```java
 private String messageDelayLevel = "1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h";
```

* level == 0，消息为非延迟消息
* 1<=level<=maxLevel，消息延迟特定时间，例如level==1，延迟1s
* level > maxLevel，则level== maxLevel，例如level==20，延迟2h

## 5. 批量消息

批量发送消息能显著提高传递小消息的性能。限制是这些批量消息应该有相同的topic，相同的waitStoreMsgOK，而且不能是延时消息。此外，这一批消息的总大小不应超过4MB。

如果您每次只发送不超过4MB的消息，则很容易使用批处理，样例如下：

```java
String topic = "BatchTest";
List<Message> messages = new ArrayList<>();
messages.add(new Message(topic, "TagA", "OrderID001", "Hello world 0".getBytes()));
messages.add(new Message(topic, "TagA", "OrderID002", "Hello world 1".getBytes()));
messages.add(new Message(topic, "TagA", "OrderID003", "Hello world 2".getBytes()));
try {
   producer.send(messages);
} catch (Exception e) {
   e.printStackTrace();
   //处理error
}
```



## 6. 事务消息

### 6.1 事务消息执行流程 

流程图：



![](https://img-blog.csdnimg.cn/20210401171744307.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNzI2ODk2,size_16,color_FFFFFF,t_70)



上图说明了事务消息的大致方案，其中分为两个流程：正常事务消息的发送及提交、事务消息的补偿流程。

#### 1）事务消息发送及提交

(1) 发送消息（half消息）。

(2) 服务端响应消息写入结果。

(3) 根据发送结果执行本地事务（如果写入失败，此时half消息对业务不可见，本地逻辑不执行）。

(4) 根据本地事务状态执行Commit或者Rollback（Commit操作生成消息索引，消息对消费者可见）

#### 2）事务补偿

(1) 对没有Commit/Rollback的事务消息（pending状态的消息），从服务端发起一次“回查”

(2) Producer收到回查消息，检查回查消息对应的本地事务的状态

(3) 根据本地事务状态，重新Commit或者Rollback

其中，补偿阶段用于解决消息Commit或者Rollback发生超时或者失败的情况。

#### 3）事务消息状态

事务消息共有三种状态，提交状态、回滚状态、中间状态：

* TransactionStatus.CommitTransaction: 提交事务，它允许消费者消费此消息。
* TransactionStatus.RollbackTransaction: 回滚事务，它代表该消息将被删除，不允许被消费。
* TransactionStatus.Unknown: 中间状态，它代表需要检查消息队列来确定状态。

### 6.2 发送事务消息

#### 1） 创建事务消息生产者

使用 `TransactionMQProducer`类创建生产者，并指定唯一的 `ProducerGroup`，就可以设置自定义线程池来处理这些检查请求。执行本地事务后、需要根据执行结果对消息队列进行回复。回传的事务状态在请参考前一节。

```java
public class TransactionProducer {
	public static void main(String[] args)
			throws MQClientException, InterruptedException {

		// 创建事务监听器
		TransactionListener transactionListener = new TransactionListenerImpl();
		// 创建消息生产者
		TransactionMQProducer producer = new TransactionMQProducer("group6");
		producer.setNamesrvAddr("139.224.103.236:9876");
		// 生产者这是监听器
		producer.setTransactionListener(transactionListener);
		// 启动消息生产者
		producer.start();
		for (int i = 1; i <= 5; i++) {
			try {
				Message msg = new Message("TransactionTopicTest",
						"transactionTag", "msg-" + i, ("Hello RocketMQ " + i)
								.getBytes(RemotingHelper.DEFAULT_CHARSET));
				SendResult sendResult = producer.sendMessageInTransaction(msg,
						null);
				// System.out.printf("%s%n", sendResult);
				TimeUnit.SECONDS.sleep(1);
			} catch (MQClientException | UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
		TimeUnit.SECONDS.sleep(Integer.MAX_VALUE);
		producer.shutdown();
	}
}
```

#### 2）实现事务的监听接口

```java
public class TransactionListenerImpl implements TransactionListener {
	private final AtomicInteger transactionIndex = new AtomicInteger(0);
	private final AtomicInteger checkTimes = new AtomicInteger(0);
	private final ConcurrentHashMap<String, Integer> localTrans = new ConcurrentHashMap<>();

	/**
	 * 本地事务的执行逻辑
	 *
	 * @param msg
	 * @param arg
	 * @return
	 */
	@Override
	public LocalTransactionState executeLocalTransaction(Message msg,
			Object arg) {

		LocalTransactionState state;

		System.out.println("执行本地事务");
		if (StringUtils.equals("msg-4", msg.getKeys())) {
			state = LocalTransactionState.COMMIT_MESSAGE;
		} else if (StringUtils.equals("msg-5", msg.getKeys())) {
			state = LocalTransactionState.ROLLBACK_MESSAGE;
		} else {
			state = LocalTransactionState.UNKNOW;
			localTrans.put(msg.getKeys(), transactionIndex.incrementAndGet());
		}
		System.out.println("executeLocalTransaction: " + msg.getKeys()
				+ ",excute state: " + state + ",current time: "
				+ DateUtils.formatLocalDateTime(LocalDateTime.now()));
		return state;
	}

	/**
	 * 回查本地事务的代码实现
	 *
	 * @param msg
	 * @return
	 */
	@Override
	public LocalTransactionState checkLocalTransaction(MessageExt msg) {
		System.out.println("checkLocalTransaction message key: " + msg.getKeys()
				+ ",current time: "
				+ DateUtils.formatLocalDateTime(LocalDateTime.now()));
		Integer index = localTrans.get(msg.getKeys());

		if (null != index) {
			switch (index) {
				case 1:
					System.out.println("check result: unknow, 回查次数："
							+ checkTimes.incrementAndGet());
					return LocalTransactionState.UNKNOW;
				case 2:
					System.out.println("check result: commit message");
					return LocalTransactionState.COMMIT_MESSAGE;
				case 3:
					System.out.println("check result: rollback message");
					return LocalTransactionState.ROLLBACK_MESSAGE;
			}
		}
		return LocalTransactionState.COMMIT_MESSAGE;
	}
}
```



#### 3）事务消息执行结果

msg-4执行本地事务成功

msg-5执行本地事务失败，回滚事务

msg-1执行本地事务失败，默认回查15次，每一次间隔60秒

msg-2执行本地事务失败，回查1次，执行成功

msg-3执行本地事务失败，回查1次，回滚事务



### 6.3 使用限制

1. 事务消息不支持延时消息和批量消息。
2. 为了避免单个消息被检查太多次而导致半队列消息累积，我们默认将单个消息的检查次数限制为 15 次，但是用户可以通过 Broker 配置文件的 `transactionCheckMax`参数来修改此限制。如果已经检查某条消息超过 N 次的话（ N = `transactionCheckMax` ） 则 Broker 将丢弃此消息，并在默认情况下同时打印错误日志。用户可以通过重写 `AbstractTransactionCheckListener` 类来修改这个行为。
3. 事务消息将在 Broker 配置文件中的参数 transactionMsgTimeout 这样的特定时间长度之后被检查。当发送事务消息时，用户还可以通过设置用户属性 CHECK_IMMUNITY_TIME_IN_SECONDS 来改变这个限制，该参数优先于 `transactionMsgTimeout` 参数。
4. 事务性消息可能不止一次被检查或消费。
5. 提交给用户的目标主题消息可能会失败，目前这依日志的记录而定。它的高可用性通过 RocketMQ 本身的高可用性机制来保证，如果希望确保事务消息不丢失、并且事务完整性得到保证，建议使用同步的双重写入机制。
6. 事务消息的生产者 ID 不能与其他类型消息的生产者 ID 共享。与其他类型的消息不同，事务消息允许反向查询、MQ服务器能通过它们的生产者 ID 查询到消费者。

