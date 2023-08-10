FROM golang:alpine AS build-env
ENV CGO_ENABLED 0
WORKDIR /app
RUN apk add --no-cache git ca-certificates make cmake
ENV GOBIN=/app/bin
RUN git clone https://github.com/ifad/clammit . && make all

# Build runtime image
FROM alpine:latest
RUN apk --no-cache add ca-certificates clamav curl && \
    addgroup -S clam && adduser -u 101 -S -G clam clam

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.26/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=7a79496cf8ad899b99a719355d4db27422396735

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

WORKDIR /home/clam

COPY launcher.sh /

# Update virus definitions, set permissions, and create required directories and files
RUN freshclam && \
    mkdir -p /var/log/clamav && touch /var/log/clamav/clamd.log && touch /var/log/clamav/freshclam.log && \
    mkdir -p /run/clamav && touch /run/clamav/clamd.pid && \
    chown -R clam:clam /run/clamav && \
    chown clam /var/spool/cron/crontabs/root && \
    chown clam /var/log/clamav/freshclam.log && \
    chown clam /var/log/clamav/clamd.log && \
    chown -R clam /var/lib/clamav/ && \
    chown clam /launcher.sh && \
    chmod g+s /var/spool/cron/crontabs/root && \
    chmod +x /launcher.sh && \
    echo "* * * * * freshclam" >> /var/spool/cron/crontabs/root 

# Configure clamd to listen on TCP
RUN echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    echo "TCPAddr 127.0.0.1" >> /etc/clamav/clamd.conf  

USER clam
COPY --from=build-env --chown=clam:clam /app/bin/clammit .
COPY --from=build-env --chown=clam:clam /app/testfiles ./testfiles

EXPOSE 8438

CMD ["sh", "/launcher.sh", "/home/clam/clammit.cfg", "/home/clam/clammit", "-config", "clammit.cfg"]
