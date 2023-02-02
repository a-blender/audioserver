# Use Ubuntu Baseimage-docker https://github.com/phusion/baseimage-docker instead of Alpine because it bundles apt
# which can install required packages for server scripts

FROM phusion/baseimage:jammy-1.0.1

WORKDIR app/

# Install golang and fswatch

RUN apt update -y && \
    apt install golang -y && \
    apt install bash -y && \
    apt install fswatch -y && \
    apt install ffmpeg -y

COPY go.mod ./
RUN go mod download

# Copy source code, scripts, and dir that the Go server watches

COPY *.go *.sh localhost.crt localhost.key ./
COPY songs songs

# Build the Go server

RUN go build -o /audioserver

# Run the Go server on container start

CMD [ "/audioserver" ]
