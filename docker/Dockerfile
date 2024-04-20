# YARRRML + RMLMapper

# FROM openjdk:18-ea-11-alpine
FROM eclipse-temurin:22_36-jdk-alpine

# install everything needed
RUN apk add --no-cache bash nodejs npm wget nmap-ncat maven git && cd / && \
    ########## YARRRML-parser ##########
    wget https://github.com/RMLio/yarrrml-parser/archive/refs/heads/master.zip && \
    unzip master.zip && rm master.zip && \
    mv /yarrrml-parser-master /yarrrml-parser && \
    cd /yarrrml-parser && \
    npm install && \
    ############# RMLMapper ############
    cd / && \
    wget https://github.com/RMLio/rmlmapper-java/archive/refs/heads/master.zip && \
    unzip master.zip && rm master.zip && \
    mv rmlmapper-java-master rmlmapper-java && \
    cd rmlmapper-java && \
    mvn -DskipTests clean package && \
    cd / && \
    mkdir /mnt/data

RUN apk add alpine-sdk ruby ruby-bundler ruby-dev
# Clean APK cache
RUN rm -rf /var/cache/apk/*
RUN mkdir /usr/app
WORKDIR /usr/app
COPY . /usr/app
RUN bundle install

RUN chmod a+x entrypoint.sh


ENTRYPOINT ["./entrypoint.sh"]
