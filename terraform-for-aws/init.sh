#!/usr/bin/env bash

# DO after `sudo -i`
yum update 
yum install java-1.8.0-openjdk-devel.x86_64 -y
/usr/sbin/alternatives --config java
java -version

rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
date

# vi /etc/bashrc : 
# [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ " to
# [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@MyServer \W]\\$ "
