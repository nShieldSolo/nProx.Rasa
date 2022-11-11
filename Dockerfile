FROM centos/systemd

# Common libaries
RUN yum -y update; yum clean all
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN yum install -y sudo
RUN yum install -y epel-release
RUN sudo yum -y install wget
# Install python 3.8

RUN yum -y groupinstall "Development Tools"
RUN yum -y install openssl-devel bzip2-devel libffi-devel xz-devel
RUN wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
RUN tar xvf Python-3.8.12.tgz
RUN cd Python-3.8*/ && ./configure --enable-optimizations && sudo make altinstall

# Source
RUN mkdir /var/www
RUN chmod 777 -R /var/www

COPY . /var/www/
RUN python3.8 -m pip install --upgrade pip
RUN cd /var/www 
RUN pip3.8 install 

# Conda 
RUN cd /tmp
RUN wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh

# RUN bash Anaconda3-2022.10-Linux-x86_64.sh

# RUN pip3.8 install -r requirements.txt