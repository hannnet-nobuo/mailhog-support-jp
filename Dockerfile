#
# MailHog Dockerfile
#

FROM golang:alpine

# Install MailHog:
RUN apk --update --no-cache add --virtual build-dependencies \
    git make bash \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && go get -d github.com/mailhog/MailHog \
  && go get -d github.com/jteeuwen/go-bindata \
  && go get -d github.com/gorilla/pat \
  && go get -d github.com/ian-kent/envconf \
  && go get -d github.com/ian-kent/go-log/log \
  && go get -d github.com/mailhog/http \
  && export PATH=$PATH:/root/gocode/bin \
  && (cd /root/gocode/src/github.com/mailhog/; git clone -b support-jp https://github.com/hannnet-nobuo/MailHog-UI.git) \
  && (cd /root/gocode/src/github.com/mailhog/MailHog-UI/;make bindata) \
  && cp /root/gocode/src/github.com/mailhog/MailHog-UI/assets/assets.go /root/gocode/src/github.com/mailhog/MailHog/vendor/github.com/mailhog/MailHog-UI/assets/ \
  && (cd /root/gocode/src/github.com/mailhog/MailHog/;make) \
  && mv /root/gocode/bin/MailHog /usr/local/bin \
  && rm -rf /root/gocode \
  && apk del --purge build-dependencies

# Add mailhog user/group with uid/gid 1000.
# This is a workaround for boot2docker issue #581, see
# https://github.com/boot2docker/boot2docker/issues/581
RUN adduser -D -u 1000 mailhog

USER mailhog

WORKDIR /home/mailhog

ENTRYPOINT ["MailHog"]

# Expose the SMTP and HTTP ports:
EXPOSE 1025 8025