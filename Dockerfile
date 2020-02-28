FROM mzz2017/git:alpine AS version
WORKDIR /build
ADD .git ./.git
RUN git describe --abbrev=0 --tags > ./version


FROM golang:alpine AS builder
ADD service /build/service
WORKDIR /build/service
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.io
COPY --from=version /build/version ./
RUN export VERSION=$(cat ./version) && go build -ldflags="-X V2RayA/global.Version=${VERSION:1}" -o V2RayA .


FROM alpine:latest
RUN apk --no-cache add iptables
WORKDIR /v2raya
COPY --from=builder /build/service/V2RayA .
ENV GIN_MODE=release
EXPOSE 2017
ENTRYPOINT "./V2RayA"
