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

# git命令整理

## 一、拉取当前分支的远程代码

git pull ：将当前分支远程上的更新拉取下来



## 二、获取本地所有分支远程代码的更新

git fetch：将远程上的更新拉取下来。不包括当前分支的更新。（仅仅是远程分支的更新）



## 三、创建分支：

1. git checkout branchName：单纯的创建了一个新的分支，并未与远程分支建立关系。
2. git checkout -b branchName origin/branchName：在本地创建一个分支，并且这个分支与远程分支相关联。



## 四、本地分支与远程分支关联

git branch  --set-upstream-to=origin/远程分支  本地分支

例如：git branch --set-upstream-to=origin/feature-2.22.2-release  feature-2.22.2-release 
；把本地dev分支和远程dev分支相关联。