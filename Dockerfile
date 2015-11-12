# centos
FROM mshige1979/centos:centos6
MAINTAINER mshige1979

# pacakge install
RUN yum install -y \
  openssh-server \
  httpd \
  supervisor

# mysql
RUN yum install -y http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
RUN yum install -y mysql-community-*

# php
RUN yum install -y --enablerepo=remi-php56 \
  php \
  php-opcache \
  php-devel \
  php-mbstring \
  php-mcrypt \
  php-mysqlnd \
  php-phpunit-PHPUnit \
  php-pecl-xdebug \
  php-pecl-xhprof

# sshd init
RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'root:root' | chpasswd
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key

# php
RUN echo '<?php phpinfo(); ?>' > /var/www/html/info.php

# mysql init
RUN /etc/init.d/mysqld start \
  && mysqladmin -u root password 'password' \
  && (echo 'grant all privileges on *.* to root@"%" identified by "password" with grant option;' | mysql -u root -ppassword) \
  && /etc/init.d/mysqld stop

# supervisord init
RUN echo '' >> /etc/supervisord.conf && \
    echo '[program:httpd]' >> /etc/supervisord.conf && \
    echo 'command=/usr/sbin/httpd -D FOREGROUND' >> /etc/supervisord.conf && \
    echo '' >> /etc/supervisord.conf && \
    echo '[program:sshd]' >> /etc/supervisord.conf && \
    echo 'command=/usr/sbin/sshd -D' >> /etc/supervisord.conf && \
    echo '' >> /etc/supervisord.conf && \
    echo '[program:mysqld]' >> /etc/supervisord.conf && \
    echo 'command=/usr/bin/mysqld_safe' >> /etc/supervisord.conf && \
    echo '' >> /etc/supervisord.conf

# port
EXPOSE 22 80 3306

# run
CMD ["/usr/bin/supervisord", "-n"]

