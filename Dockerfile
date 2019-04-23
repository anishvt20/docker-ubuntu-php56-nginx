FROM ubuntu:16.04

LABEL maintainer="anishvt20@gmail.com"

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository -y ppa:ondrej/php &&\
    add-apt-repository -y ppa:nginx/stable &&\
    apt-get update &&\
    apt-get install -y \
      nginx \
      php5.6-fpm php5.6-cli php5.6-cgi \
      php5.6-interbase php5.6-mysql \
      php5.6-curl php5.6-mbstring php5.6-mcrypt\
      php5.6-gd php5.6-xml php5.6-zip php5.6-json

RUN apt-get install -y nodejs npm supervisor curl ruby mcrypt wget sudo

# Update NPM
RUN npm update

# Set Node as executable
RUN ln -s `which nodejs` /usr/bin/node

# Timezone conf
RUN cp -vf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

## PHP conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/5.6/fpm/php.ini
RUN sed -i "s/;daemonize = yes/daemonize = no/" /etc/php/5.6/fpm/php-fpm.conf
ADD ./docker/php-fpm.conf /etc/php/5.6/fpm/php-fpm.conf
ADD ./docker/www.conf /etc/php/5.6/fpm/pool.d/www.conf
#
# Install composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit.phar \
        && chmod +x phpunit.phar \
        && mv phpunit.phar /usr/local/bin/phpunit

# nginx conf
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
ADD ./docker/vhost.conf /etc/nginx/sites-available/default

# Supervisor conf
ADD ./docker/supervisord.conf /etc/supervisor/supervisord.conf

# forward request and error logs to docker log collector
RUN ln -sf /tmp/supervisord.log /var/log/nginx/access.log \
    && ln -sf /tmp/supervisord.log /var/log/nginx/error.log

# EXPOSE PORTS
EXPOSE 80

# Start
CMD ["supervisord", "--nodaemon"]
