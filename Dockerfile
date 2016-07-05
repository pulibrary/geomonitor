FROM rails:4.2.3

MAINTAINER Eliot Jordan <eliot.jordan@gmail.com>

RUN apt-get update && apt-get upgrade -y && \
    apt-get -y install \
        unzip \
        wget \
        git \
        curl

WORKDIR /usr/src

RUN git clone https://github.com/pulibrary/geomonitor.git

WORKDIR /usr/src/geomonitor

# Add thin server gem
RUN echo "\ngem 'thin'" >> Gemfile

RUN bundle install

# Add default env variable referencing our solr container
# Depends on --link my_solr_container:solr
ENV SOLR_URL http://solr:8983/solr/geoblacklight

ADD config/database.yml /usr/src/geomonitor/config/database.yml

RUN rake db:create && rake db:migrate

EXPOSE 3000

CMD ["bundle", "exec", "thin", "start"]
