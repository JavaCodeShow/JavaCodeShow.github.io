---
author: 江峰
title: "使用hexo写博客"
date: 2022-06-11 22:15
comments: true
categories: hexo
summary: 个人使用hexo记录博客，记录一些常用命令以及方法。
tags: 
	- hexo

---



# 使用hexo写博客

## 环境安装

node的版本号一定要正确，不然可能会出现版本不适配等一系列问题。这里node使用12.18.3版本

node下载：https://nodejs.org/download/release/v12.18.3/

下载文件为：node-v12.18.3-x64.msi 

```
git version
node -v
npm -v
```

## npm缓存清除

```
npm cache clean --force
```

## npm镜像

国内npm比较慢，安装cnpm淘宝镜像

```
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

## 重新生成node_modules

```
rm -rf node_modules && npm install --force
```

## 安装hexo

```
npm install -g hexo-cli
```

## 部署插件

```
npm install hexo-deployer-git --save
```

## 使用以及部署

```
hexo clean #清理各种缓存和旧文件
hexo g     #生成静态文件
hexo s     #开启服务器预览
hexo d     #部署到git服务器上
```

