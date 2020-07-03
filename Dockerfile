ARG CENTOS_TAG=7.8.2003

FROM centos:${CENTOS_TAG}
LABEL maintainer="Varlog Err <varlog.err@gmail.com"

ARG MARIADBCLI_V=10.4
ARG PHP_V=7.4

COPY resources/http/root/ /

RUN : \
  && CENT_V="$(rpm -E '%{rhel}')" \
  # Configure MariaDB repo
  && yum -y install \
    # Install base tools
    tar openssl grep sed coreutils unzip zip \
    # and installer specific tools
    sudo policycoreutils iproute \
    # and epel with remi
    epel-release \
    https://rpms.remirepo.net/enterprise/remi-release-${CENT_V}.rpm \
  # Install MariaDB repo
  && cat /tmp/MariaDB.repo | sed -e "s/{{cent_v}}/${CENT_V}/g;s/{{maria_v}}/${MARIADBCLI_V}/g" \
    | tee /etc/yum.repos.d/MariaDB.repo \
  # Install httpd
  && yum -y install httpd mod_ssl \
  # Install php
  && yum -y --enablerepo="remi-php${PHP_V/./}" install \
    php \
    php-mysqlnd \
    php-cli \
    php-gd \
    php-intl \
    php-mbstring \
    php-pdo \
    php-xml \
    php-pecl-zip \
    php-pecl-redis5 \
  && mv /tmp/mpm.conf "$(find /etc/httpd/conf.modules.d -name '*mpm.conf' | head -1)" \
  # Install mariadb client
  && yum -y --enablerepo=mariadb install MariaDB-client \
  # Cleanup
  && yum -y autoremove \
  && yum --enablerepo='*' clean all \
  && find /tmp /var/cache/yum -mindepth 1 -maxdepth 1 | xargs rm -rf \
  && rm -rf /var/tmp/yum-* \
  && find /var/log/ -type f | xargs truncate -s 0 \
  # fix tmp chmod
  && chmod 1777 /tmp

EXPOSE 80 443
