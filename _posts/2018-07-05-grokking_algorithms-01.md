---
layout: post
title: '《算法图解》之简介'
date: 2018-07-06
author: yysue
categories: algorithm
tags: algorithm
cover: 'http://7xkmkl.com1.z0.glb.clouddn.com/algorithm-banner.jpg'
---

> 以最经典的二分查找开头，引入**大O表示法**来表述运行时间，与极限类似，常数不重要，最重要的是阶（类似高阶无穷小）。 

![](http://7xkmkl.com1.z0.glb.clouddn.com/algorithm-banner.jpg)

## 二分查找

二分查找

- 一般而言，对于包含n个元素的列表，用二分查找最多需要$\log_2 n$步，而简单查找最多需要n步。
- $\lg 100$ 相当于"将多少个10相乘的结果为100"
- 对数运算是幂运算的逆运算

Python实现二分查找

```python
def binary_search(my_list, item):
    low = 0
    high = len(my_list) - 1

    while low <= high:
        mid = low + ((high-low)>>1) # 这样写会越界 mid = (low + high) // 2
        guess = my_list[mid]
        if guess == item:
            return mid
        if guess > item:
            high = mid - 1
        else:
            low = mid + 1
    return None

my_list = [1, 3, 5, 7, 9]

print(binary_search(my_list, 3)) # => 1
print(binary_search(my_list, -1)) # => None
```

## 大O表示法

大O表示法指出了最糟情况下的运行时间

常见的大O运行时间

1. O($logn$)
2. O(n)
3. O(n*$log n$)
4. O($n^2$)
5. O(n!)

![](http://7xkmkl.com1.z0.glb.clouddn.com/2018-07-05_235727.png)

启示：

- 算法的速度指的并非时间，而是操作数的增速
- 谈论算法的速度时，我们说的是随着输入的增加 ，其运行时间将以什么样的速度增加
- 算法的运行时间用大O表示法表示

旅行商问题

- 旅行商问题就是排列问题，旅行商要浏览5个城市，求最短行程，时间复杂度为O(n!)

## 参考

- [算法图解](https://zhuanlan.zhihu.com/p/26564380)
- https://github.com/egonschiele/grokking_algorithms