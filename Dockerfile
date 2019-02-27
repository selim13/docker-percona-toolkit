FROM centos:7
LABEL maintainer="Dmitry Seleznyov <selim013@gmail.com>"

RUN groupadd -g 1001 mysql
RUN useradd -u 1001 -r -g 1001 -s /sbin/nologin \
    -c "Default Application User" mysql

RUN export GNUPGHOME="$(mktemp -d)"; \
    KEY='430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A'; \
    (gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$KEY" \
        || gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$KEY" \
        || gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$KEY") \
    && gpg --export --armor "$KEY" > ${GNUPGHOME}/RPM-GPG-KEY-Percona \
    && rpmkeys --import ${GNUPGHOME}/RPM-GPG-KEY-Percona /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
    && curl -L -o /tmp/percona-release.rpm https://repo.percona.com/centos/7/RPMS/noarch/percona-release-0.1-8.noarch.rpm \
    && rpmkeys --checksig /tmp/percona-release.rpm \
    && yum install -y /tmp/percona-release.rpm \
    && rm -rf "$GNUPGHOME" /tmp/percona-release.rpm \
    && rpm --import /etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY \
    && percona-release disable all \
    && percona-release enable tools release

ENV TOOLKIT_VERSION 3.0.13-1.el7

RUN yum install -y \
    percona-toolkit-${TOOLKIT_VERSION} \
    && yum clean all \
    && rm -rf /var/cache/yum /var/lib/mysql

USER mysql