FROM golang:1.17-alpine AS build
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags '-extldflags "-static"' -o dummy-pdf-or-png

FROM scratch
WORKDIR /
COPY --from=build /build/dummy-pdf-or-png /build/dummy.pdf /build/dummy.png /build/corrupt-dummy.pdf /
ENTRYPOINT ["/dummy-pdf-or-png"]
