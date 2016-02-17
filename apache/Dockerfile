FROM ubuntu:latest
MAINTAINER Satheeshkumar Manoharan  <infosatheesh2020@gmail.com>

#COPY ./concrete/ /usr/local/apache2/htdocs
RUN apt-get update
RUN apt-get -y upgrade

# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl curl lynx-cur php5-mcrypt vim unzip

# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid

EXPOSE 80

RUN echo 'safe_mode = Off' > /etc/php5/apache2/conf.d/safe.ini

# Copy site into place.
#ADD ./concrete/ /var/www/html
ADD ./concrete5.7.5.5.zip /var/www/html/
RUN unzip /var/www/html/concrete5.7.5.5.zip -d /var/www/html && rm /var/www/html/concrete5.7.5.5.zip && mv /var/www/html/concrete5.7.5.5 /var/www/html/concrete && chown -R www-data:www-data /var/www/html/concrete
ADD ./index.php /var/www/html/

# Update the default apache site with the config we created.
ADD ./apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default remove old PID file if already present and simply start apache.
CMD rm -f /var/run/apache2/apache2.pid && /usr/sbin/apache2ctl -D FOREGROUND
