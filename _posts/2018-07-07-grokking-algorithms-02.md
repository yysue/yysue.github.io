---
layout: post
title: '《算法图解》之选择排序'
date: 2018-07-07
author: yysue
categories: algorithm
tags: algorithm
cover: 'http://7xkmkl.com1.z0.glb.clouddn.com/algorithm-banner.jpg'
---

> 讲述内存中的基础**数据结构**，数组擅长找元素，链表擅长找位置，为了适应对数据不同的操作要求，应当灵活使用。

## 1. 内存的工作原理

计算机内存犹如有很多抽屉的柜子.

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180707-220622.jpg)



![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180707-220646.jpg)

## 2. 数组和链表

数组中元素的位置称为索引    元素xx位于索引xx处

数组与链表不同操作对应的时间复杂度

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180707-222144.jpg)

## 3. 选择排序

定义:遍历这个数组,取出最大的元素添加到新数组中并在元数组中删除这个最大元素,再次遍历这个数组...直到原数组为空

Python实现选择排序
```python
def findSmallest(arr):
    smallest = arr[0]
    smallest_index = 0
    for i in range(1, len(arr)):
        if arr[i] < smallest:
            smallest = arr[i]
            smallest_index = i
    return smallest_index

def selectionSort(arr):
    newArr = []
    for i in range(len(arr)):
        smallest = findSmallest(arr)
        newArr.append(arr.pop(smallest))
    return newArr

print(selectionSort([5, 3, 6, 2, 10])) # [2, 3, 5, 6, 10]
```

