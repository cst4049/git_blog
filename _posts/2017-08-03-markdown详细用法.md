---
layout: post
title: mongo的http访问
date: 2017-08-01
categories: blog
tags: [python]
description:  Do It Easier
---
mongo 的http访问
mongod --rest --httpinterface

1.列出databaseName数据库中的collectionName集合下的所有数据：
http://127.0.0.1:28017/databaseName/collectionName/
2.给上面的数据集添加一个limit参数限制返回10条
http://127.0.0.1:28017/databaseName/collectionName/?limit=-10
3.给上面的数据加上一个skip参数设定跳过5条记录
http://127.0.0.1:28017/databaseName/collectionName/?skip=5
4.同时加上limit限制和skip限制
http://127.0.0.1:28017/databaseName/collectionName/?skip=5&limit=10
5.按条件{a:1}进行结果筛选（在关键字filter后面接上你的字段名）
http://127.0.0.1:28017/databaseName/collectionName/?filter_a=1
6.加条件的同时再加上limit限制返回条数
http://127.0.0.1:28017/databaseName/collectionName/?filter_a=1&limit=-10
7.执行任意命令
如果你要执行特定的命令，可以通过在admin.$cmd上面执行find命令，同样的你也可以在REST API里实现，如下，执行{listDatabase:1}命令：
http://localhost:28017/admin/$cmd/?filter_listDatabases=1&limit=1
8.查询集合的记录个数：
http://host:port/db/$cmd/?filter_count=collection&limit=1
