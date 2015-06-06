FROM centos:centos6
MAINTAINER Yoshi Sakai <info@bluemooninc.jp>

ENV LANG ja_JP.UTF-8

# Upgrade to latest version
RUN rpm -Uvh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm &&\
    yum -y upgrade

# install packages
RUN yum -y install vim git
RUN yum -y install passwd openssh openssh-server openssh-clients sudo
RUN yum -y install curl ntp unzip wget &&\
    yum -y clean all

# Time Zone
RUN echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock

RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN ntpdate ntp.nict.jp

# Install Open JDK 7
RUN yum -y install java-1.7.0-openjdk &&\
    yum -y clean all

# Install Jenkins
RUN groupadd -g 1001 jenkins
RUN useradd -c "Jenkins Continuous Build server" \
        -u 1001 -g 1001 -d /var/lib/jenkins -s /bin/bash jenkins
RUN wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo &&\
    rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key &&\
    yum -y install jenkins &&\
    yum -y clean all

# Install Jenkins Plugins
RUN wget -nv -T 60 -t 3 -P /var/lib/jenkins/plugins \
        https://updates.jenkins-ci.org/latest/scm-api.hpi &&\
    wget -nv -T 60 -t 3 -P /var/lib/jenkins/plugins \
        https://updates.jenkins-ci.org/latest/git-client.hpi &&\
    wget -nv -T 60 -t 3 -P /var/lib/jenkins/plugins \
        https://updates.jenkins-ci.org/latest/git.hpi &&\
    wget -nv -T 60 -t 3 -P /var/lib/jenkins/plugins \
        https://updates.jenkins-ci.org/latest/ansicolor.hpi &&\
    chown -R jenkins:jenkins /var/lib/jenkins/plugins

# Set up SSH
RUN mkdir -p /home/docker/.ssh; chown docker /home/docker/.ssh; chmod 700 /home/docker/.ssh
ADD id_rsa.pub /home/docker/.ssh/authorized_keys
RUN chown docker /home/docker/.ssh/authorized_keys
RUN chmod 600 /home/docker/.ssh/authorized_keys

# Setup sudoers
RUN echo "docker ALL=(ALL) ALL" >> /etc/sudoers.d/docker

# Set up SSHD config
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Init SSHD
RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop

#  Python Supervisord  
RUN yum -y install python-setuptools
RUN easy_install pip
RUN easy_install supervisor

ADD supervisord.conf /etc/supervisord.conf

# Set the port to 22 8080
EXPOSE 22 8080

# run service by supervisord
CMD ["supervisord","-n"]
