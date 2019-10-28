FROM golang:latest

RUN go get github.com/google/go-jsonnet/cmd/jsonnet

COPY . .

RUN ./test.sh