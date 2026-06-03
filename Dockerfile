FROM registry.redhat.io/3scale-amp2/system-rhel9:3scale2.16.3
USER root

COPY ./oracle-client-files/instantclient-basic*-linux.*.zip \
     ./oracle-client-files/instantclient-sdk-linux.*.zip \
     ./oracle-client-files/instantclient-odbc-linux.*.zip \
     /opt/system/vendor/oracle/

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_18/ \
    ORACLE_HOME=/opt/oracle/instantclien_19_18/ \
    DB=oracle \
    TZ=utc \
    NLS_LANG=AMERICAN_AMERICA.UTF8

RUN dnf install wget unzip make ruby-devel gcc gcc-c++ redhat-rpm-config libaio libnsl2 -y \
    && ./script/oracle/install-instantclient-packages.sh \
    && bundle config build.ruby-oci8 --with-instant-client-include=/opt/oracle/instantclient_19_18/sdk/include --with-instant-client-lib=/opt/oracle/instantclient_19_18 \
    && bundle install --local --jobs $(grep -c processor /proc/cpuinfo) --retry=5

USER 1001
