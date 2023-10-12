FROM ruby:3

WORKDIR /scripts
RUN gem install indeed-ruby activesupport fileutils yaml
COPY ./scripts .

