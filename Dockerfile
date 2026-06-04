FROM registry.redhat.io/3scale-amp2/system-rhel9:3scale2.16.3

USER root

COPY ./oracle-client-files/instantclient-basic*-linux.x64*.zip \
     ./oracle-client-files/instantclient-sdk-linux.x64*.zip \
     ./oracle-client-files/instantclient-odbc-linux.x64*.zip \
     /opt/system/vendor/oracle/

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient/:$LD_LIBRARY_PATH \
    ORACLE_HOME=/opt/oracle/instantclient/ \
    DB=oracle \
    TZ=utc \
    NLS_LANG=AMERICAN_AMERICA.UTF8

RUN mkdir -p vendor/oracle \
    && dnf install wget unzip make ruby-devel gcc gcc-c++ redhat-rpm-config libaio libnsl2 -y \
    && LIBNSL=$(find /usr/lib64 -maxdepth 1 -name "libnsl.so.*" ! -name "libnsl.so.1" | head -n 1) \
    && if [ -n "$LIBNSL" ]; then ln -sf $LIBNSL /usr/lib64/libnsl.so.1; fi \
    && ./script/oracle/install-instantclient-packages.sh \
    && echo "/opt/oracle/instantclient_19_18" > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig \
    && ln -sf /opt/oracle/instantclient_19_18/sdk/include /opt/oracle/instantclient_19_18/include \
    && ln -sf /opt/oracle/instantclient_19_18 /opt/oracle/instantclient_19_18/lib64 \
    && bundle config build.ruby-oci8 "--with-instant-client-dir=/opt/oracle/instantclient_19_18" \
    && bundle install --local --jobs $(grep -c processor /proc/cpuinfo) --retry=5

USER 1001
