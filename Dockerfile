FROM ruby:2.5.3-stretch

# Install Ruby and Rails dependencies
RUN apt-get update && apt-get install -y build-essential libxml2-dev libcurl4-openssl-dev curl wget

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
