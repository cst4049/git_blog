#!/bin/bash

#* 基于Ubuntu-16S，创建一个虚拟机模板Adam
#* 相关的脚本。


#* 交互式增添加用户
sudo adduser stoneman
sudo usermod -aG sudo stoneman

#* 为stoneman配置sudo免密
USER=stoneman
echo | sudo tee -a /etc/sudoers.d/${USER}  << EOF
${USER} ALL=(ALL) NOPASSWD: ALL
EOF
sudo chmod 0440 /etc/sudoers.d/${USER}


#* 如果只能公钥登录，需要手动先添加公钥
su stoneman
touch ~/.ssh/authorized_keys                                                                                                                                                                                                                       
chmod 600 ~/.ssh/authorized_keys 
chown -R stoneman:stoneman ~/.ssh/
read -p "Input Pub Key:" PubKey ;\
echo "$PubKey" >> ~/.ssh/authorized_keys


# step 1: 安装必要的一些系统工具

sudo apt-get update

sudo apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

# step 2: 安装GPG证书

curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg \
  | sudo apt-key add -
  
#- Step 3: 写入软件源信息
# sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
echo "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee -a /etc/apt/sources.list.d/docker.list

# Step 4: 更新并安装 Docker-CE
sudo apt-get -y update
sudo apt-get -y --allow-unauthenticated install docker-ce  # 阿里环境中必须加上--allow-unauthenticated才行

# Step 5: 配置拉去映像的镜像，配置docker0的地址
echo | sudo tee -a /etc/docker/daemon.json  << DEAMON_JSON
{
  "registry-mirrors": [ 
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "bip": "172.20.0.1/16"
}
DEAMON_JSON

sudo systemctl restart docker


# 添加stoneman到docker组

sudo usermod -aG docker stoneman



# = 更改hostname名

read OldName < /etc/hostname ;\
read -p "Input Name Hostname:" NewName ;\
sudo sed -i "s/$OldName/$NewName/" /etc/hostname ;\
sudo sed -i "s/$OldName/$NewName/" /etc/hosts ;\

# - 在127.0.0.1 后面加上 127.0.1.1 作为另一个名称映射
sudo sed -i  '/^127.0.0.1/a 127.0.1.1\t$NewName' /etc/hosts
echo "hostname changed $OldName=>$NewName"





# 更改ip

echo "original ens160:"
# sed -n '/ens160/p' /etc/network/interfaces
# sudo sed -i '/ens160/d' /etc/network/interfaces
# 使用限定性更强的正则表达式
sed -n  '/\(auto\|iface\) ens160/p' /etc/network/interfaces
sudo sed -i  '/\(auto\|iface\) ens160/d' /etc/network/interfaces
read ith ;\
echo | sudo tee -a /etc/network/interfaces  << ETC_NETWORK_INTERFACES
auto ens160
iface ens160 inet static
address 172.17.12.$ith
netmask 255.255.0.0
gateway 172.17.2.1
dns-nameservers 172.17.9.10 114.114.114.114
ETC_NETWORK_INTERFACES
