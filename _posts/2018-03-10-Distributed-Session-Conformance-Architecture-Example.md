---
layout: post
title: "分布式下Session一致性架构举例"
date: 2018-03-11 00:01:01
category: architecture
tags: [架构,Session,分布式]
---
## 一、问题及方案

见这篇文章：[分布式下Session一致性问题](https://my.oschina.net/u/159293/blog/1625569)

## 二、分布式环境搭建：

![](http://7xkmkl.com1.z0.glb.clouddn.com/20180311_001.png)

系统环境

```shell
[root@centos7 ~]# cat /etc/redhat-release 
CentOS Linux release 7.4.1708 (Core) 
[root@centos7 ~]# 
```

### 2.1 安装jdk

```shell
# 下载jdk-8u141-linux-x64.tar.gz
# 创建目录
mkdir -p /opt/java
# 解压
tar -xzvf jdk-8u141-linux-x64.tar.gz -C /opt/java
# 创建链接
ln -s /opt/java/jdk1.8.0_141 /usr/local/jdk
# 设置变量 /etc/profile末尾添加
export JAVA_HOME=/usr/local/jdk
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
# 使变量生效
source /etc/profile
export PATH=$JAVA_HOME/bin:$PATH
# 验证
java -version
```

### 2.2 安装tomcat

安装3个tomcat并设置其端口号

```shell
# 下载apache-tomcat-8.5.16.tar.gz
# 创建目录
mkdir -p /opt/tomcat
# 解压
tar -xzvf apache-tomcat-8.5.16.tar.gz -C /opt/tomcat
# 清空ROOT目录
rm -rf /opt/tomcat/apache-tomcat-8.5.16/webapps/ROOT/*
# 复制3个tomcat
cd /opt/tomcat
cp -a apache-tomcat-8.5.16 tomcat1
cp -a apache-tomcat-8.5.16 tomcat2
cp -a apache-tomcat-8.5.16 tomcat3
# 修改端口号
sed -i '22s/8005/8'"$i"'05/' $file
sed -i '69s/8080/8'"$i"'80/' $file
sed -i '116s/8009/8'"$i"'09/' $file
```

修改如下3个端口号

![](http://7xkmkl.com1.z0.glb.clouddn.com/20180311_002.png)

用如下脚本修改：a.sh

```shell
#!/bin/sh

for i in {1..3}
do
  file=/opt/tomcat/tomcat"$i"/conf/server.xml
  sed -i '22s/8005/8'"$i"'05/' $file
  sed -i '69s/8080/8'"$i"'80/' $file
  sed -i '116s/8009/8'"$i"'09/' $file
  #sed -i '148s#appBase=".*"#appBase="/data/webapps"#' $file
done
```

执行脚本修改端口

```shell
sh a.sh
执行后，3个tomcat的端口号分别改为
8180,8280,8380
```

启动并验证这3个tomcat

```shell
# 分别向3个tomcat写入一个测试文件a.txt
for i in {1..3};do echo 8"$i"80>/opt/tomcat/tomcat"$i"/webapps/ROOT/a.txt;done

# 启动
for i in {1..3};do /opt/tomcat/tomcat"$i"/bin/startup.sh;done

# 验证
for i in {1..3};do curl 127.0.0.1:8"$i"80/a.txt;done
```

![](http://7xkmkl.com1.z0.glb.clouddn.com/20180311_003.png)

### 2.3 安装nginx

```shell
# 下载nginx-1.13.9.tar.gz
mkdir -p /opt/nginx/nginx-1.3.13.9
# 创建用户
useradd nginx -s /sbin/nologin -M
# 安装pcre openssl
yum install pcre pcre-devel openssl openssl-devel -y
# 解压、编译安装
tar -xzvf nginx-1.13.9.tar.gz
cd nginx-1.13.9
./configure --user=nginx --group=nginx --prefix=/opt/nginx/nginx-1.13.9 --with-http_stub_status_module --with-http_ssl_module
make
make install
# 创建链接
ln -s /opt/nginx/nginx-1.13.9 /usr/local/nginx
# 设置环境变量
echo 'export PATH=/usr/local/nginx/sbin:$PATH' >> /etc/profile
source /etc/profile
```

nginx常用命令

```shell
# 启动
nginx
# 检查配置文件
nginx -t
# 平滑启动
nginx -s reload
# 检查
netstat -tunlp | grep nginx
```

遇到的问题：

```shell
nginx: [emerg] getpwnam("nginx") failed
未创建nginx用户
```

配置nginx

/usr/local/nginx/conf/nginx.conf

```shell
worker_processes  1;
events {
    worker_connections  1024;
}

# http最外层模块
http {
	# 全局变量参数
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

	upstream web_pool {
		server 127.0.0.1:8180 weight=1;
		server 127.0.0.1:8280 weight=1;
		server 127.0.0.1:8380 weight=2;
	}

	# server相当于虚拟站点
    server {
        listen       80;
        server_name  localhost;
        location / {
            proxy_pass  http://web_pool;
            index  index.html index.htm;
        }
    }
}
```

测试一下

```shell
for i in {1..9};do curl 127.0.0.1/a.txt;done
```

![](http://7xkmkl.com1.z0.glb.clouddn.com/20180311_004.png)

### 2.4 安装redis

```shell
wget http://download.redis.io/releases/redis-4.0.8.tar.gz
mkdir -p /opt/redis
tar -xzvf redis-4.0.8.tar.gz -C /opt/redis/
ln -s /opt/redis/redis-4.0.8 /usr/local/redis
cd /usr/local/redis
make && make install

# 配置让其他机器也可以访问
vi /usr/local/redis/redis.conf
#bind 127.0.0.1
bind 0.0.0.0
```

操作redis

```shell
# 查看redis版本
redis-cli -v
# 启动redis
redis-server redis.conf > /tmp/redis.log 2>&1 &
# or
nohup redis-server redis.conf &
# 监控redis
redis-cli -h 192.168.234.130 -p 6379 monitor
# 关闭redis
redis-cli -h 127.0.0.1 -p 6379 shutdown
```

客户端

```shell
# 连接
redis-cli -h 192.168.5.220
# 查看
keys *
# 清空
flushall
```



## 三、问题重现

### 3.1 web应用

[java-web-login](https://gitee.com/yysue/demo-projects/tree/master/java-web/java-web-login)

只实现登录功能

```shell
/login   登录页面，已登录跳转到/index
/logout  退出
/index   首页，未登录跳转到/login
```

将这个应用部署到3个tomcat上

重启tomcat

```shell
for i in {1..3};do /opt/tomcat/tomcat"$i"/bin/shutdown.sh;done
for i in {1..3};do /opt/tomcat/tomcat"$i"/bin/startup.sh;done
```

![](http://7xkmkl.com1.z0.glb.clouddn.com/20180311_006.png)

![](http://7xkmkl.com1.z0.glb.clouddn.com/20180311_005.png)

### 3.2 问题描述

登录界面是8280端口，输入用户名密码点击登录，由于nginx配置的是基于轮询的算法进行分发，8380端口的服务器处理的登录，因此session创建于8380端口，而8280处于非登录状态。

## 四、解决实现

### 4.1 session sticky

修改nginx的分发算法改为基于ip

```shell
upstream web_pool {
	# 默认是轮询
	ip_hash;
	server 127.0.0.1:8180 weight=1;
	server 127.0.0.1:8280 weight=1;
	server 127.0.0.1:8380 weight=2;
}
```

修改后重启nginx

```shell
nginx -t
nginx -s reload
```

### 4.2 session replication

http://tomcat.apache.org/tomcat-8.5-doc/cluster-howto.html

tomcat配置server.xml

```xml
<!--修改每个tomcat下的conf/server.xml-->
<!--其中Receiver这个结点的端口分别配置为4001,4002,4003-->
<!--channelSendOptions-->
<!--8表示异步发送 2表示确认发送 4表示同步发送 10表示同步+确认-->
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" 
	channelSendOptions="8">
	<Manager className="org.apache.catalina.ha.session.DeltaManager" 
		expireSessionsOnShutdown="false" 
		notifyListenersOnReplication="true" />
	<Channel className="org.apache.catalina.tribes.group.GroupChannel">
		<!-- 228.0.0.4是主播地址-->
		<Membership className="org.apache.catalina.tribes.membership.McastService"
			address="228.0.0.4" 
			port="45564" 
			frequency="500" 
			dropTime="3000" />
		<Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
			address="auto" 
			port="4001" 
			autoBind="100" 
			selectorTimeout="5000"
			maxThreads="6" />
		<Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
			<Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender" />
		</Sender>
		<Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector" />
		<Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatchInterceptor" />
	</Channel>
	<Valve className="org.apache.catalina.ha.tcp.ReplicationValve" filter="" />
	<Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve" />
	<Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
		tempDir="/tmp/war-temp/" 
		deployDir="/tmp/war-deploy/" 
		watchDir="/tmp/war-listen/"
		watchEnabled="false" />
	<ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener" />
</Cluster>
```

tomcat的配置web.xml

```shell
# 修改每个tomcat下的conf/web.xml不起作用
# 一定要修改每个应用的web.xml，在<web-app>这个节点下添加
<distributable />
```

### 4.3 session数据集中存储

数据存储到redis，使用spring-data-redis

见应用[java-web-login](https://gitee.com/yysue/demo-projects/tree/master/java-web/java-web-login)

把web_spring-redis.xml重命名为web.xml，部署到tomcat即可，得先启动redis参照“安装redis”这一节。

spring-redis.xml

```xml
	<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:context="http://www.springframework.org/schema/context"
	xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

	<!-- 引入配置文件 -->
	<bean id="propertyConfigurer"
		class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
		<property name="locations">
			<list>
				<value>classpath*:redis.properties</value>
			</list>
		</property>
	</bean>

	<bean id="redisHttpSessionConfiguration"
		class="org.springframework.session.data.redis.config.annotation.web.http.RedisHttpSessionConfiguration">
		<property name="maxInactiveIntervalInSeconds" value="600"/>
	</bean>

	<bean id="jedisPoolConfig" class="redis.clients.jedis.JedisPoolConfig">
		<property name="maxTotal" value="${redis.pool.maxTotal}" />
		<property name="maxIdle" value="${redis.pool.maxIdle}" />
	</bean>

	<bean id="jedisConnectionFactory"
		class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory"
		destroy-method="destroy">
		<property name="hostName" value="${redis.hostname}" />
		<property name="port" value="${redis.port}" />
		<property name="timeout" value="${redis.timeout}" />
		<property name="usePool" value="true" />
		<property name="poolConfig" ref="jedisPoolConfig" />
	</bean>
</beans>
```

注意：

- Spring版本的选择  >=4.0.3

pom.xml

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.yysue</groupId>
	<artifactId>java-web-login</artifactId>
	<packaging>war</packaging>
	<name>java-web-login</name>
	<version>0.0.1-SNAPSHOT</version>

	<properties>
		<java.version>1.8</java.version>
		<spring.version>4.0.3.RELEASE</spring.version>
	</properties>

	<!-- 依赖 -->
	<dependencies>
		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>javax.servlet-api</artifactId>
			<version>3.0.1</version>
			<scope>provided</scope>
		</dependency>

		<dependency>
			<groupId>javax.servlet.jsp</groupId>
			<artifactId>jsp-api</artifactId>
			<version>2.2</version>
			<scope>provided</scope>
		</dependency>

		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>jstl</artifactId>
			<version>1.2</version>
		</dependency>

		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-core</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-web</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-oxm</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-tx</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-webmvc</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context-support</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-aop</artifactId>
			<version>${spring.version}</version>
		</dependency>

		<dependency>
			<groupId>org.springframework.data</groupId>
			<artifactId>spring-data-redis</artifactId>
			<version>1.5.2.RELEASE</version>
		</dependency>

		<dependency>
			<groupId>org.springframework.session</groupId>
			<artifactId>spring-session-data-redis</artifactId>
			<version>1.2.2.RELEASE</version>
		</dependency>

		<dependency>
			<groupId>redis.clients</groupId>
			<artifactId>jedis</artifactId>
			<version>2.8.1</version>
		</dependency>

	</dependencies>

	<build>
		<!-- 插件 -->
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<configuration>
					<source>${java.version}</source>
					<target>${java.version}</target>
				</configuration>
			</plugin>
		</plugins>
	</build>
</project>
```

