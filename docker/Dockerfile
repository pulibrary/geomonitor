FROM rails:4.2.3

MAINTAINER Eliot Jordan <eliot.jordan@gmail.com>

RUN apt-get update && apt-get upgrade -y && \
    apt-get -y install \
        unzip \
        git \
        curl \
        wget

WORKDIR /usr/src

RUN git clone https://github.com/pulibrary/geomonitor.git

WORKDIR /usr/src/geomonitor

# Add thin server gem
RUN echo "\ngem 'thin'" >> Gemfile

RUN bundle install

ADD database.yml config/database.yml

EXPOSE 3000

CMD ["bundle", "exec", "thin", "start"]
