FROM golang:1.16-alpine

WORKDIR app/

COPY go.mod ./
RUN go mod download

# Copy source code, scripts, and songs dir that the Go server watches
COPY *.go *.sh songs localhost.crt localhost.key ./

# Run the Go server
RUN go build -o /audioserver

CMD [ "/audioserver" ]
