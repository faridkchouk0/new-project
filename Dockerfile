FROM ubuntu:20.04
#désactive linvite de commende penadant l'instalation
ARG DEBIAN_FRONTEND=noninteractive

#mise a jour du gestioneaire de paquet
RUN apt update

#instale nginx,php-fpm
RUN apt install -y nginx php-fpm supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

#definit  lenvironement 
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.4/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf 

#démarre php dans le nginx (virtualhost)
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}

#copy supervisor config
COPY supervisord.conf ${supervisor_conf}

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Copy start.sh script and define default command for the container
COPY start.sh /start.sh
CMD ["./start.sh"]

# Expose Port for the Application 
EXPOSE 80 443
