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

RUN yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel make sqlite-devel -y
RUN curl https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz --output /tmp/Python-3.7.9.tgz
WORKDIR /tmp
RUN tar xzf Python-3.7.9.tgz
WORKDIR /tmp/Python-3.7.9
RUN ./configure --enable-optimizations
RUN yum install make -y
RUN make altinstall
RUN yum install which -y
WORKDIR /tmp
RUN rm -r Python-3.7.9.tgz
RUN yum -y install epel-release
RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py
RUN python3.7 get-pip.py
RUN python3.7 -m pip install --upgrade pip

# Source
RUN mkdir /var/www
RUN chmod 777 -R /var/www

COPY . /var/www/
RUN cd /var/www 
RUN python3.7 -m venv ./venv
RUN source ./venv/bin/activate
RUN pip3 install -U --user pip && pip3 install rasa
WORKDIR /tmp/Python-3.7.9
RUN make install
WORKDIR /var/www
RUN rasa train
COPY /kestrel-rasa.service /etc/systemd/system/kestrel-rasa.service

# RUN bash Anaconda3-2022.10-Linux-x86_64.sh

# RUN pip3.8 install -r requirements.txt