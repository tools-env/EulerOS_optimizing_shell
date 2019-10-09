#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

github="zhangjianying"
sh_ver="v1.0.0"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

# 0 允许其他用户切换Root用户
change_rootUser(){
  sed '4d' /etc/pam.d/su
  echo "#auth           required        pam_wheel.so use_uid">> /etc/pam.d/su
  echo -e "${Tip} 需要重启才能生效!!!"
}

# 1 优化TCP参数与open files
optimizing_system(){
  sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf

  echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1">>/etc/sysctl.conf
sysctl -p

echo "* soft  nofile  1000000
* hard  nofile  1000000
* soft  noproc  1000000
* hard  noproc  1000000
root soft  nofile  1000000
root hard  nofile  1000000
root soft  noproc  1000000
root hard  noproc  1000000">/etc/security/limits.conf
	echo "ulimit -SHn 1000000">>/etc/profile
  echo -e "${Tip} 需要重启系统后，才能生效系统优化配置"
}

# 2 设置更新源
setSource(){
sudo echo "[EulerOS-base]
name=EulerOS-base
baseurl=http://developer.huawei.com/ict/site-euleros/euleros/repo/yum/2.2/os/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://developer.huawei.com/ict/site-euleros/euleros/repo/yum/2.2/os/RPM-GPG-KEY-EulerOS">/etc/yum.repos.d/EulerOS-base.repo
yum repolist
}

# 3 关闭防火墙
close_fileWALL(){
  sudo systemctl stop firewalld.service   # 关闭防火墙
  sudo systemctl disable firewalld.service # 重启后默认不开启防火墙

#关闭selinx 否则docker使用会有问题
sudo sed -i '/SELINUX=enforcing/d' /etc/selinux/config
sudo sed -i '/SELINUX=disabled/d' /etc/selinux/config
echo "
SELINUX=disabled
">>/etc/selinux/config

echo -e "${Tip} 需要重启才能生效!!!"
}

# 4 时区优化
opt_timeZone(){
   sudo timedatectl set-timezone Asia/Shanghai
   sudo yum -y install ntp
   sudo ntpdate ntp1.aliyun.com
}

# 5 中文字体安装
opt_installchinese(){
sudo yum install wqy-zenhei-fonts
sed -i '/LANG/d' ~/.bash_profile
sed -i '/LANGUAGE/d' ~/.bash_profile
sed -i '/LC_ALL/d' ~/.bash_profile

sudo echo "LANG=\"zh_CN.UTF-8\"
LANGUAGE=\"zh_CN:zh\"
LC_ALL=\"zh_CN.UTF-8\"
">> ~/.bash_profile

sed -i '/LANG/d' /etc/environment
sed -i '/LANGUAGE/d' /etc/environment
sed -i '/LC_ALL/d' /etc/environment

sudo echo "LANG=\"zh_CN.UTF-8\"
LANGUAGE=\"zh_CN:zh\"
LC_ALL=\"zh_CN.UTF-8\"
">> /etc/environment
}

#6 安装docker环境
install_docker(){
  sudo yum install -y yum-utils device-mapper-persistent-data   lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum-config-manager --enable docker-ce-edge
  sudo yum install -y docker-ce.x86_64
  sudo service docker start

# 配置阿里镜像. 加速下载
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://i1el1i0w.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
}


# 7 VIM优化
opt_vim(){
sudo yum install -y vim
sed -i "/set nocompatible/d" /etc/vimrc
sed -i "/set showmode/d" /etc/vimrc
sed -i "/set number/d" /etc/vimrc
sed -i "/set ruler/d" /etc/vimrc
sed -i "/syntax on/d" /etc/vimrc
sed -i "/set lbr/d" /etc/vimrc
sed -i "/set tabstop=4/d" /etc/vimrc
echo "
set nocompatible
set showmode
set number
set ruler
syntax on
set lbr
set tabstop=4
">> /etc/vimrc
}




# 21 安装JDK
install_JDK(){
read -p "输入JDK安装路径  :" jdkPath
mkdir -fR "${jdkPath}"
mkdir -p "${jdkPath}"
cd "${jdkPath}"
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn/java/jdk/8u221-b11/230deb18db3e4014bb8e3e8324f81b43/jdk-8u221-linux-x64.tar.gz

tar -zxvf jdk-*.tar.gz
rm -f jdk-*.tar.gz

#配置环境变量
jdk_home="${jdkPath}/jdk1.8.0_221"
sed -i '/export JAVA_HOME/d' ~/.bash_profile
sed -i '/export CLASSPATH/d' ~/.bash_profile
sed -i '/export PATH=${jdkPath}/d' ~/.bash_profile

echo "export JAVA_HOME=${jdk_home}
export CLASSPATH=${jdk_home}/lib:.:${jdk_home}/jre/lib
export PATH=${jdk_home}/bin:\$PATH
">> ~/.bash_profile

source ~/.bash_profile
}

# 22 设置当前用户提示符
setHomeUser(){
echo "
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[36;40m\]\w\[\e[0m\]]\\$"
export PS1
">> ~/.bash_profile
}


#23 安装maven环境
install_maven(){
  read -p "输入maven安装路径  :" mavenPath
  mkdir -fR "${mavenPath}"
  mkdir -p "${mavenPath}"
  cd "${mavenPath}"
  rm apache-maven*.zip*
  wget http://mirrors.hust.edu.cn/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.zip
  unzip apache-maven-3.5.4-bin.zip
  rm -f   apache-maven*.zip*
  M2_Home="${mavenPath}/apache-maven-3.5.4"
  sed -i '/export M2_HOME/d' ~/.bash_profile

echo "export M2_HOME=${M2_Home}
export PATH=${M2_Home}/bin:\$PATH
">> ~/.bash_profile

source ~/.bash_profile

# 增加本地仓库路径
sed -i "s/<localRepository>\\/path\\/to\\/local\\/repo<\\/localRepository>/--><localRepository>~\\/mvnRep<\\/localRepository><!--/g" "${M2_Home}/conf/settings.xml"
# 增加mvn 阿里源
sed -i "s/<\\/mirrors>/<mirror><id>alimaven<\\/id><name>aliyun maven<\\/name><url>http:\\/\\/maven.aliyun.com\\/nexus\\/content\\/groups\\/public\\/<\\/url><mirrorOf>central<\\/mirrorOf><\\/mirror><\\/mirrors>/g" "${M2_Home}/conf/settings.xml"
}


# 24 安装node环境
install_node(){
   read -p "输入node安装路径  :" nodePath
   mkdir -p "${nodePath}"
   cd "${nodePath}"
   rm node-*.tar.gz*

   wget https://npm.taobao.org/mirrors/node/v12.7.0/node-v12.7.0-linux-x64.tar.gz
   tar -zxvf node-v12.7.0-linux-x64.tar.gz
   rm node-v12.7.0-linux-x64.tar.gz

   node_home="${nodePath}/node-v12.7.0-linux-x64"
   sed -i '/export NODE_HOME/d' ~/.bash_profile

echo "
export NODE_HOME=${node_home}
export PATH=${node_home}/bin:\$PATH
">> ~/.bash_profile
  # /bin/sh -c "sudo rm -f /usr/bin/node && sudo ln -s \"${node_home}/bin/node\" /usr/bin/node"

  source ~/.bash_profile
  npm install -g cnpm --registry=https://registry.npm.taobao.org
}



# 8 docker环境下的redis
  install_docker_redis(){
    sudo docker pull bitnami/redis
    echo -e " ----------------------   运行以下命令启动    --------------------------------"
    echo -e "${info} docker run -d -p 16379:6379 --name redis -e REDIS_PASSWORD=password123 bitnami/redis:latest"
    echo -e "${info} 更多命令参考 : https://hub.docker.com/r/bitnami/redis/"
  }

  # 9 docker环境下的alimysql
install_docker_AliMysql(){

  #需要修改配置 否则tokuDB引擎会无法启动.然后数据库启动就跪
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
  sudo chmod a+x /etc/rc.local

echo"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
">>/etc/rc.local

  read -p "输入aliMysql数据库存储路径  :" mySqlDataPath

   mkdir -p "${mySqlDataPath}/data"
   mkdir -p "${mySqlDataPath}/logs"
   docker pull tekintian/alisql
   echo "[mysqld]
basedir=/usr/local/mysql
datadir=/data/mysql/data
user=mysql
port =3306
max_connections = 1650
table_open_cache = 2000
lower_case_table_names = 1
event_scheduler=ON
wait_timeout = 86400
sort_buffer_size = 848KB
read_buffer_size = 848KB
read_rnd_buffer_size = 432KB
join_buffer_size = 432KB
net_buffer_length = 16K
thread_cache_size = 100
skip_name_resolve
symbolic-links=0
default-time_zone = '+8:00'

[mysqld_safe]

[client]
   " > "${mySqlDataPath}/my.cnf"

   echo -e " ----------------------   运行以下命令启动    --------------------------------"
   echo -e "${info} docker run   -it -d -p 13306:3306 -e MYSQL_ROOT_PASSWORD=123456 -v ${mySqlDataPath}/my.cnf:/usr/local/mysql/etc/my.cnf  -v ${mySqlDataPath}/data:/data/mysql/data -v ${mySqlDataPath}/logs:/data/mysql/log tekintian/alisql"
   echo -e " ----------------------   启动后到docker中运行一下命令开启远程访问    --------------------------------"
   echo -e " grant all PRIVILEGES on *.* to root@'%'  identified by '123456';"
   echo -e " flush privileges; "
}

#开始菜单
start_menu(){
clear
Version=$(lsb_release -r --short)
Codename=$(lsb_release -c --short)
OSArch=$(uname -m)
echo && echo -e " euler server 一键安装管理脚本 ${Red_font_prefix}[${sh_ver}]${Font_color_suffix}
  -- coolzlay | blog.csdn.net/zhangjianying --
 当前系统:  ${Codename} ${Version} ${OSArch}
# ————————————内核管理(需要root)————————————
#  ${Green_font_prefix}[0].${Font_color_suffix} 允许其他用户切换Root用户
#  ${Green_font_prefix}[1].${Font_color_suffix} 优化TCP参数与open files(偏web短连接应用)
#  ${Green_font_prefix}[2].${Font_color_suffix} 设置华为源
#  ${Green_font_prefix}[3].${Font_color_suffix} 关闭防火墙与selinx(系统默认只打开22端口)
#  ${Green_font_prefix}[4].${Font_color_suffix} 设置中国时区(东8,设置阿里校时服务器)
#  ${Green_font_prefix}[5].${Font_color_suffix} 中文字体安装(支持java环境下图片输出中文)
#  ${Green_font_prefix}[6].${Font_color_suffix} 安装docker环境
#  ${Green_font_prefix}[7].${Font_color_suffix} 优化vim操作习惯设置
#  ${Green_font_prefix}[8].${Font_color_suffix} 安装 docker环境下的redis
#  ${Green_font_prefix}[9].${Font_color_suffix} 安装 docker环境下的ALiMysql(含tokudb引擎)
# ————————————开发环境(不需要root)————————————
#  ${Green_font_prefix}[21].${Font_color_suffix} Oracle JDK8u221 安装
#  ${Green_font_prefix}[22].${Font_color_suffix} 设置当前用户提示符PS1环境变量
#  ${Green_font_prefix}[23].${Font_color_suffix} 安装Maven环境
#  ${Green_font_prefix}[24].${Font_color_suffix} 安装node v12.7.0环境

# ————————————————————————————————"

read -p " 请输入对应操作数字 :" num
  case "$num" in
      0)
      change_rootUser
      ;;
      1)
      optimizing_system
      ;;
      2)
      setSource
      ;;
      3)
      close_fileWALL
      ;;
      4)
      opt_timeZone
      ;;
      5)
      opt_installchinese
      ;;
      6)
      install_docker
      ;;
      7)
      opt_vim
      ;;
      8)
      install_docker_redis
      ;;
      9)
      install_docker_AliMysql
      ;;
      21)
      install_JDK
      ;;
      22)
      setHomeUser
      ;;
      23)
      install_maven
      ;;
      24)
      install_node
      ;;

      *)
      clear
      echo -e "${Error}:请输入正确数字 "
      sleep 1s
      start_menu
      ;;
  esac

}


start_menu