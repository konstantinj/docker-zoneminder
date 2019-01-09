FROM centos:7
RUN yum -y install epel-release \
 && yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm \
 && yum -y install supervisor mod_ssl zip file mysql zoneminder \
 && yum clean all \
 && ln -sf /etc/zm/www/zoneminder.conf /etc/httpd/conf.d/ \
 && echo "ServerName localhost" > /etc/httpd/conf.d/servername.conf \
 && echo -e "# Redirect the webroot to /zm\nRedirectMatch permanent ^/$ /zm" > /etc/httpd/conf.d/redirect.conf
VOLUME /var/lib/zoneminder /var/log/zoneminder
EXPOSE 80 443
ENV ZM_SERVER_HOST=localhost \
	ZM_MYSQL_ENGINE=MyISAM \
	ZM_DB_HOST=mysql \
	ZM_DB_PORT=3306 \
	ZM_DB_NAME=zoneminder \
	ZM_DB_USER=zoneminder \
	ZM_DB_PASS=zoneminder
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY supervisord.conf /etc/
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
