FROM postgres:14
LABEL maintainer="Carlesandro Gaspar-carlesandrogaspar@gmail.com"

ARG ORA2PG_VERSION=23.1
RUN mkdir /app
WORKDIR /app

#mudando bando para enconding UTF-8/pt_BR
RUN localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.utf-8
ENV LANG pt_BR.UTF-8

RUN apt-get update && apt-get install -y -q --no-install-recommends \
        cpanminus \
        nano \
        unzip \
        curl \
        ca-certificates \
        rpm \
        alien \
        libaio1 \
        # Install postgresql
        #postgresql-client \
        libaio-dev \
        #instalar Perl Database Interface
        libdbi-perl \
        bzip2 \
        libpq-dev \
        gnupg2 \
        libdbd-pg-perl

ADD /assets /assets

RUN mkdir /usr/lib/oracle/12.2/client64/network/admin -p
#copia configurações do arquivo tnsnames.ora para o diretório do cliente oracle
COPY conf_client_oracle/tnsnames.ora /usr/lib/oracle/12.2/client64/network/admin/
#instação client Oracle
RUN alien -i /assets/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm &&\
    alien -i /assets/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm &&\
    alien -i /assets/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm
#setando variáveis de ambiente
ENV ORACLE_HOME=/usr/lib/oracle/12.2/client64
ENV TNS_ADMIN=/usr/lib/oracle/12.2/client64/network/admin/
ENV LD_LIBRARY_PATH=/usr/lib/oracle/12.2/client64/lib
ENV PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/oracle/12.2/client64/bin

# Instalar DBI modulo com Postgres, Oracle e Compress::Zlib module
RUN cpan install Test::NoWarnings &&\
    cpan install DBI &&\
    cpan install DBD::Pg &&\
    cpan install Bundle::Compress::Zlib &&\
    cpanm install DBD::Oracle@1.82

# Instalar ora2pg
RUN curl -L -o /tmp/ora2pg.zip https://github.com/darold/ora2pg/archive/v$ORA2PG_VERSION.zip &&\
    (cd /tmp && unzip ora2pg.zip && rm -f ora2pg.zip) &&\
    mv /tmp/ora2pg* /tmp/ora2pg &&\
    (cd /tmp/ora2pg && perl Makefile.PL && make && make install)
