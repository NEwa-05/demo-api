FROM golang:latest as builder

WORKDIR /root/

RUN git clone https://github.com/containous/foobar-api.git

RUN cd foobar-api && CGO_ENABLED=0 go build -a --trimpath --installsuffix cgo --ldflags="-s" -o whoami

FROM scratch

WORKDIR /root/

COPY --from=builder /root/foobar-api/whoami ./

CMD [ "./whoami" ]