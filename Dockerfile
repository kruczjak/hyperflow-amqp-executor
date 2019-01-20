FROM ruby:2.5.3-alpine3.8

# Install Ruby and Rails dependencies
RUN apk --no-cache --update add ruby-dev build-base libxml2-dev curl-dev

COPY . /hyperflow-amqp-executor
WORKDIR /hyperflow-amqp-executor

RUN gem build hyperflow-amqp-executor.gemspec && \
    gem install hyperflow-amqp-executor

CMD hyperflow-amqp-executor
