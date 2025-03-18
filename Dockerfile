# syntax=docker/dockerfile:1
FROM alpine:latest AS build

RUN apk add --no-cache gcc libpcap-dev musl-dev make

ENV TCPDUMP_VERSION=4.99.5

RUN wget http://www.tcpdump.org/release/tcpdump-${TCPDUMP_VERSION}.tar.gz \
 && tar -xvf tcpdump-${TCPDUMP_VERSION}.tar.gz \
 && cd tcpdump-${TCPDUMP_VERSION} \
 && CFLAGS=-static ./configure --without-crypto \
 && make \
 && mv tcpdump /

FROM scratch

COPY --from=wildwildangel/setcap-static /setcap-static /!setcap-static
COPY --from=build /tcpdump /tcpdump

RUN ["/!setcap-static", "cap_net_raw=+iep", "/tcpdump"]

USER 65534:65534

ENTRYPOINT ["/tcpdump"]
