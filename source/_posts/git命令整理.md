---
author: 江峰
title: "git命令整理"
date: 2020-05-11 22:15
comments: true
categories: git
summary: 对git命令进行整理，方便后续使用。
tags: 
	- git
---

<meta name="referrer" content="no-referrer" />

# git命令整理

## 拉取当前分支的远程代码

git pull ：将当前分支远程上的更新拉取下来



## 获取本地所有分支远程代码的更新

git fetch：将远程上的更新拉取下来。不包括当前分支的更新。（仅仅是远程分支的更新）



## 修改本地指向远程仓库的地址

1. 查看本地远程仓库地址

   ```
   git remote -v
   ```

   

2. 修改仓库地址

   ```
   git remote set-url origin https://github.91chifun.workers.dev//https://github.com/JavaCodeShow/JavaCodeShow.github.io.git
   ```

   

