FROM centos:centos6
MAINTAINER Yoshi Sakai <info@bluemooninc.jp>
ENV LANG ja_JP.UTF-8

# Add RPM
RUN wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
RUN rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

# install packages
RUN yum -y install vim git
RUN yum -y install passwd openssh openssh-server openssh-clients sudo
RUN yum -y install curl ntp unzip wget 
RUN yum -y install jenkins

# Time Zone
RUN echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN ntpdate ntp.nict.jp

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
