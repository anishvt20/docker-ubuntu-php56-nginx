FROM 409863963302.dkr.ecr.eu-west-1.amazonaws.com/ubuntu-php56-nginx:latest

# Create Application folder
RUN mkdir -p /var/www/application \
    && mkdir -p /var/log/application \
    && usermod -u 1000 www-data \
    && chown -R www-data:www-data /var/www/application \
    && chown -R www-data:www-data /var/log/application

# Define Volumes
VOLUME /var/www/application

# Set Workdir
WORKDIR /var/www/application

ADD --chown=www-data:www-data . /var/www/application

RUN composer install

ADD --chown=www-data:www-data app/config/parameters_docker.yml app/config/parameters.yml

ADD --chown=www-data:www-data codeception_docker.yml codeception.yml

RUN npm update -g

RUN npm install

RUN sudo npm install -g grunt grunt-cli

RUN bin/console doctrine:migrations:migrate --no-interaction

RUN grunt

RUN bin/console xsd:dump
