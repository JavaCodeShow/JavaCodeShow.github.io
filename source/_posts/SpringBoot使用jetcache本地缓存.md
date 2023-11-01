---
author: 江峰
title: "SpringBoot使用jetcache本地缓存"
date: 2020-05-12 22:15
comments: true
categories: 高性能缓存
summary: 通过docker启动redis。
tags: 
	- jetcache

---

<meta name="referrer" content="no-referrer" />

# SpringBoot使用jetcache本地缓存

## 引入mavne依赖

```
<dependency>
	<groupId>com.alicp.jetcache</groupId>
	<artifactId>jetcache-starter-redis</artifactId>
	<version>2.6.4</version>
</dependency>
```

## 添加配置文件

```
# cache 状态监控刷新时间
jetcache.statIntervalMinutes=1
jetcache.areaInCacheName=false
# 进程内的并发访问保护默认开关
jetcache.penetrationProtect=true
jetcache.local.default.type=caffeine
jetcache.local.default.keyConvertor=fastjson
# 默认单个 method cache 支持数量100个，需要具体看服务情况调整
jetcache.local.default.limit=100
# 缓存失效时间，全局默认10s
jetcache.local.default.expireAfterWriteInMillis=10000

```

## 开启缓存

在启动类上添加@EnableMethodCache注解，扫描指定包下面的@Cached注解，使缓存生效。

注意：jetcache是基于AOP的，所以需要放在public方法上，并且不能是本类方法调用。

```
@SpringBootApplication
@EnableMethodCache(basePackages = "xxx.xxx")
public class RedisSpringBootMain {
    public static void main(String[] args) {
        SpringApplication.run(RedisSpringBootMain.class, args);
    }
}
```

## 缓存名称删除规则

AreaName+cacheName, cacheName 如果未指定，则通过类签名+函数签名+参数签名实现

## 使用缓存

key支持spel表达式，可自定义key的生成规则。不指定key，则使用默认规则

```
   /**
     * 单个key
     */
    @PostMapping("/jetCacheGet")
    @Cached(cacheType = CacheType.LOCAL, expire = 6)
    public BaseResult<List<UserDTO>> jetCacheGet(@RequestBody String bizShowId) {
        log.info("从数据库获得数据");
        return BaseResult.success(UserDTO.getUserList());
    }
```

```
     /**
     * 对象
     */
    @PostMapping("/jetCacheGet2")
    @Cached(cacheType = CacheType.LOCAL, expire = 6)
    public BaseResult<List<UserDTO>> jetCacheGet2(@RequestBody UserDTO userDTO) {
        log.info("从数据库获得数据");
        return BaseResult.success(UserDTO.getUserList());
    }

```

```
    /**
     * 集合排序
     */
    @PostMapping("/jetCacheGet3")
    @Cached(cacheType = CacheType.LOCAL, key = "T(com.jf.common.utils.jetcache.JetCacheUtils).sorted(#bizShowIdList)", expire = 6)
    public BaseResult<List<UserDTO>> jetCacheGet3(@RequestBody List<String> bizShowIdList) {
        log.info("从数据库获得数据");
        return BaseResult.success(UserDTO.getUserList());
    }
```

```
    /**
     * 集合对象排序
     */
    @PostMapping("/jetCacheGet4")
    @Cached(cacheType = CacheType.LOCAL, key = "T(com.jf.common.utils.jetcache.JetCacheUtils).sorted(#UserDTO)", expire = 6)
    public BaseResult<List<UserDTO>> jetCacheGet4(@RequestBody List<UserDTO> userDTOList) {
        log.info("从数据库获得数据");
        return BaseResult.success(UserDTO.getUserList());
    }
```



