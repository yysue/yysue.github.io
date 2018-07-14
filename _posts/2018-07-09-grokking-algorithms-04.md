---
layout: post
title: '《算法图解》之快速排序'
date: 2018-07-09
author: yysue
categories: algorithm
tags: algorithm
cover: 'http://7xkmkl.com1.z0.glb.clouddn.com/algorithm-banner.jpg'
---

> 以前一章的递归为基础，讲述“**分而治之**”，即D&C。重点讲述二分查找的基础——快速排序。

## 1 分而治之

分而治之(divide and conquer, D&C)一种著名的递归式问题解决方法.

### demo1

假设你是农场主,有一小块土地,你要将这块土地均匀地分成方块,且分出的方块要尽可能大.

```python
def land(x, y):
    if (x == y): # 基线条件
        return x
    else: # 循环条件
        z = x - y
        if z > y:
            x = z
        else:
            x = y
            y = z
        return land(x, y)

print(land(1680, 640)) # 80
```

### demo2

给定一个数字数组,将这些数字相加,并返回结果.

```python
# 使用循环
def sum(arr):
    total = 0
    for x in arr:
        total += x
	return total

print(sum([1, 2, 3, 4])) # 10

# 使用递归
def sum(arr, i, ans):
    if len(arr) > i:
        return sum(arr, i+1, ans + arr[i])
	else:
        return ans
    
print(sum([1, 2, 3, 4], 0, 0)) # 10
```

## 2 快速排序

基准值:pivot

分区:partitioning

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-040900.jpg)

```python
def quicksort(array):
    if len(array) < 2:
        return array
    else:
        pivot = array[0] # 将第一个元素作为基准值
        less = [i for i in array[1:] if i <= pivot] # 小于基准值的数组
        greater = [i for i in array[1:] if i > pivot] # 大于基准值的数组
        return quicksort(less) + [pivot] + quicksort(greater)
    
print(quicksort([10, 5, 2, 3]))
print(quicksort([3, 5, 2, 1, 4]))
```

## 3 再谈大O表示法

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-034359.jpg)

### 3.1 比较合并排序和快速排序

快速排序在平均情况下运行时间为O(nlogn),而合并排序的运行时间总是O(nlogn),为何不使用合并排序?

因为它们的常量不一样,假设快速排序每一步1毫秒,合并排序的每一步需要1秒

### 3.2 平均情况和最糟情况

快速排序的性能高度依赖于选择的基准值

最糟情况:

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-041922.jpg)

一般情况:

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-041937.jpg)

平均情况:

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-042015.jpg)

## 4 小结

- D&C将问题逐步分解,使用D&C处理列表时,基线条件很可能是空数组或只包含一个元素或数组
- 实现快速排序时,请随机地选择用作基准值的元素,快速排序的平均运行时间为O(nlogn)
- 大O表示法中的常量有时候很重要,这就是快速排序比合并排序快的原因
- 在比较二分查找和简单查找时,常量无关紧要,因为列表很长时,O(logn)比O(n)快得多







