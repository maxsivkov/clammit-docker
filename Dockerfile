FROM golang:alpine AS build-env
ENV CGO_ENABLED 0
WORKDIR /app 
RUN apk add --no-cache git mercurial ca-certificates git make cmake 
RUN git clone https://github.com/ifad/clammit . && make all

# Build runtime image
FROM alpine:latest
LABEL maintainer="Max Sivkov <maxsivkov@gmail.com>"
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=build-env /app/bin/clammit .
COPY --from=build-env /app/testfiles ./testfiles
COPY launcher.sh .
ENTRYPOINT ["sh", "/app/launcher.sh", "/app/clammit.cfg", "/app/clammit", "-config", "clammit.cfg"]

