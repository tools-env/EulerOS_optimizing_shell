# EulerOS_optimizing_shell
华为EulerOS默认系统优化

EulerOS默认安全设置的挺高的.比如

* 不准root用户 ssh登录

* 默认创建的用户不能中途su 切换到root等

* 默认用户密码必须大小写+数字+符号的组合

* 默认开启防火墙只开放22 ssh端口

  

因此在使用该脚本前,先要确保已经设置好网络并且能ssh上后再执行.下面给出系统安装好以后可能需要手工设置的一些地方

## 打开网络
1、cd /etc/sysconfig/network-scripts/ 
2、ls查看网卡
3、修改该文件 vi ifcfg-ens33
4、我们需要首先找到ONBOOT=no ，需要修改为ONBOOT=yes然后保存退出。 
5、service network restart #重启网络服务

## 创建用户

```shell
adduser coolzlay  # coolzlay 是你要设置的用户名
passwd coolzlay # 设置密码 . 这里必须设置一个大小写+符号+数字的密码
chmod -v u+w /etc/sudoers  #准备添加用户的sodu权限
vim /etc/sudoers

## Allow root to run any commands anywhere 
root ALL=(ALL) ALL
coolzlay ALL=(ALL) ALL #这个是新用户


chmod -v u-w /etc/sudoers # 还原设置文件的只读
```



## 本脚本的一些设置项

\# ————————————内核管理(需要root)————————————

\#   允许其他用户切换Root用户

\#  优化TCP参数与open files(偏web短连接应用)

\#   设置华为源

\#  关闭防火墙与selinx(系统默认只打开22端口)

\#  设置中国时区(东8,设置阿里校时服务器)

\#   中文字体安装(支持java环境下图片输出中文)

\#   安装docker环境

\#  优化vim操作习惯设置

\#   安装 docker环境下的redis

\#  安装 docker环境下的ALiMysql(含tokudb引擎)

\# ————————————开发环境(不需要root)————————————

\#  Oracle JDK8u221 安装

\#  设置当前用户提示符PS1环境变量

\#  安装Maven环境

\#   安装node v12.7.0环境





## 使用的注意事项

脚本中涉及的docker容器均来自官方hub或者阿里镜像. 建议用于开发环境.

生产环境还是自己做镜像吧. 我可不管用 什么阿狗阿猫都能上传的官方镜像