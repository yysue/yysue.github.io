---
layout: post
title: '《算法图解》之递归'
date: 2018-07-09
author: yysue
categories: algorithm
tags: algorithm
cover: 'http://7xkmkl.com1.z0.glb.clouddn.com/algorithm-banner.jpg'
---

> 讲述**递归**，即调用函数自身的编程方法，递归需要的 基线条件即最简单状态，递归条件即指导函数将条件引向最简状态。由于递归的特殊性，调用栈必不可少，栈为先进后出的数据结构，类似高斯消元法的“向前——向后”，我们将问题逐渐堆高简化，再从高处解决，带入底端，此为调用栈。

## 1 递归

假设要找一把钥匙,而钥匙在下面的盒子里.

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-010303.jpg)

使用一种方法(while循环):

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-010331.jpg)

另一种方法(递归):

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-010349.jpg)

## 2 基线条件和递归条件

```python
def countdown(i):
    print(i)
    if i <= 0: # 基线条件
        return
    else: # 递归条件
        countdown(i-1)

countdown(5)
```

## 3 栈

### 3.1 调用栈

```python
def greet(name):
    print('hello, ', name)
    greet2(name)
    print('getting ready to say bye...')
    bye()
    
def greet2(name):
    print('how are you, ', name)

def bye():
    print('ok bye!')
    
greet('maggie')
```

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-014658.jpg)

### 3.2 递归调用栈

```python
# 使用递归
def fact(x):
    if x == 1:
        return 1
    else:
        return x * fact(x-1)

print(fact(3))

# 使用循环
def fact2(x):
    ans = 1
    while (x > 1):
        ans = ans * x
        x = x - 1
	return ans

print(fact2(3))
```

![](http://7xkmkl.com1.z0.glb.clouddn.com/Jietu20180709-020317.jpg)

栈在递归中扮演着重要角色,使用栈虽然很方便,但是也要付出代价:存储详尽的信息可能战胜大量的内存.每个函数调用都要战胜一定的内存,如果栈很高,就意味着计算机存储了大量函数调用的信息.在这种情况下,有两种选择:

- 使用循环
- 使用尾递归

## 4 小结

- 递归指的是调用自己的函数
- 每个递归函数都有两个条件:基线条件和递归条件
- 栈有两种操作:压入和弹出
- 所有函数调用都进入调用栈
- 调用栈可能很长,这将占用大量的内存