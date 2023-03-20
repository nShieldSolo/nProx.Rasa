FROM centos/systemd

# Install Common services
RUN yum -y update; yum clean all
RUN yum -y install openssh-server passwd; yum clean all
RUN mkdir /var/run/sshd
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
RUN echo 'root:11052194' | chpasswd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

# Install Common lib
RUN yum install -y epel-release
RUN yum install -y nano
RUN yum install -y wget
RUN yum install -y git


# Install RASA
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
RUN sudo yum -y install sqlite-devel

RUN python3.7 -m venv ./venv
RUN source ./venv/bin/activate
RUN pip3 install -U --user pip && pip3 install rasa
WORKDIR /tmp/Python-3.7.9
RUN make install


RUN sudo mkdir /var/rasa 
WORKDIR /var/rasa 
RUN git clone https://github.com/nShieldSolo/nProx.Rasa.git
COPY /helpers/kestrel-rasa.service /etc/systemd/system/kestrel-rasa.service

RUN yum install -y dos2unix
COPY /helpers/script.sh script.sh
RUN dos2unix script.sh

WORKDIR /var/rasa 


# Output
#SSH
EXPOSE 22
# Rasa 
EXPOSE 8090


CMD [ "/usr/sbin/init" ]
