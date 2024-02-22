FROM ruby:3.3.0-alpine3.18

WORKDIR /dual_focus

COPY Gemfile Gemfile.lock ./

RUN apk  --no-cache add linux-headers\
                        libxml2-dev\
                        make\
                        gcc\
                        libc-dev\
                        nodejs\
                        tzdata\
                        mysql-client \
                        mysql-dev \
                        git \
                        less \
                        curl \
                        coreutils \
                        gnupg \
                        imagemagick \
                        graphviz \
                        tmux \
                        go \
                        yarn &&\
    apk add --virtual build-dependencies --no-cache build-base curl-dev &&\
    gem install bundler --no-document --version 2.5.6 && \
    bundle install -j4 &&\
    apk del build-dependencies

COPY . .

RUN yarn install && yarn cache clean

EXPOSE 3000
