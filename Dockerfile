# syntax = docker/dockerfile:experimental

ARG BASE_IMAGE=gcr.io/distroless/base

FROM golang:latest as builder

# Build
WORKDIR $GOPATH/src/github.com/owenthereal/echo-webhook
COPY . .
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN --mount=type=cache,target=/root/.cache/go-build go install ./...

FROM $BASE_IMAGE

WORKDIR /app
ENV PATH="/app:${PATH}"

COPY --from=builder /go/bin/* /app

ENTRYPOINT ["/app/echo-webhook"]
