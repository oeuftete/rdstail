FROM golang:1.8.7-alpine AS build

RUN apk add --no-cache --update git=2.11.3-r0 build-base=0.4-r1

#  For caching
RUN go get -v -d github.com/Sirupsen/logrus
RUN go get -v -d github.com/aws/aws-sdk-go/aws
RUN go get -v -d github.com/aws/aws-sdk-go/aws/session
RUN go get -v -d github.com/aws/aws-sdk-go/service/rds
RUN go get -v -d github.com/chrismrivera/backoff
RUN go get -v -d github.com/urfave/cli

COPY . .

RUN go get -v -d
RUN go build -a -installsuffix cgo -o rdstail .

FROM golang:1.8.7-alpine

# Get certificates since we need to talk to AWS on HTTPS.
RUN apk add --no-cache --update ca-certificates=20161130-r1
RUN update-ca-certificates

# Do not run as root.
USER nobody

COPY --from=build /go/rdstail /rdstail
ENTRYPOINT ["/rdstail"]
