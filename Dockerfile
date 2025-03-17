FROM alpine:latest

RUN /bin/sh -c 'apk add --no-cache tcpdump coreutils libcap'
RUN setcap cap_net_raw=eip /usr/bin/tcpdump

USER nobody:nobody
ENTRYPOINT ["/usr/bin/tcpdump"]
