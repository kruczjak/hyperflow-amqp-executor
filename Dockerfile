FROM ruby:2.5.3-alpine3.8

# Install Ruby and Rails dependencies
RUN apk --no-cache --update add ruby-dev build-base libxml2-dev curl-dev libnsl-dev curl wget bash

ADD http://pegasus.isi.edu/montage/Montage_v3.3_patched_4.tar.gz /
RUN tar zxvf Montage_v3.3_patched_4.tar.gz && \
    make -C /Montage_v3.3_patched_4 && \
    echo "export PATH=\$PATH:/Montage_v3.3_patched_4/bin" >> /etc/bash.bashrc

COPY . /hyperflow-amqp-executor
WORKDIR /hyperflow-amqp-executor

ENV PATH $PATH:/Montage_v3.3_patched_4/bin

RUN gem build hyperflow-amqp-executor.gemspec && \
    gem install hyperflow-amqp-executor

CMD hyperflow-amqp-executor
