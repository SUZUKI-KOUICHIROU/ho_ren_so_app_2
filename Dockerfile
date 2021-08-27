FROM ruby:2.6.3-alpine

ENV LANG="C.UTF-8" \
    PACKAGES="curl-dev build-base alpine-sdk tzdata sqlite-dev less ruby-dev nodejs"

RUN apk update && \
    apk add --no-cache --update $PACKAGES

WORKDIR /var/www

COPY ./ ./

RUN gem install bundler && \
    bundle install -j4

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]