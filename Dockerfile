FROM postgres:9.6.0

RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y --force-yes build-essential git-core libv8-dev curl postgresql-server-dev-$PG_MAJOR libxml-parser-perl \
    && rm -rf /var/lib/apt/lists/* 

# install plv8
ENV PLV8_BRANCH r1.4

RUN cd /tmp && git clone -b $PLV8_BRANCH https://github.com/plv8/plv8.git \
  && cd /tmp/plv8 \
  && make all install

# install pg_prove
RUN curl -LO http://xrl.us/cpanm \
    && chmod +x cpanm \
    && ./cpanm TAP::Parser::SourceHandler::pgTAP


# install pgtap
ENV PGTAP_VERSION v1.0.0
RUN git clone git://github.com/theory/pgtap.git \
    && cd pgtap && git checkout tags/$PGTAP_VERSION \
    && make
	
# install converter	
RUN ./cpanm -f TAP::Harness::Archive TAP::Formatter::JUnit	
	
ADD ./test.sh /test.sh
RUN chmod +x /test.sh

WORKDIR /

CMD ["/test.sh"]
ENTRYPOINT ["/test.sh"]
