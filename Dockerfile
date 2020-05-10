# https://www.lucasepe.it/posts/golang-static-builds/
############################
# STEP 1 build executable binary
############################
FROM golang:1.14-alpine as builder

# Install Git + UPX.
RUN apk update && \
 apk add --no-cache upx git ca-certificates tzdata && \
 update-ca-certificates && \
 addgroup --system app && adduser -S -G app app

# Set the Current Working Directory inside the container
WORKDIR $GOPATH/src/github.com/luizbafilho/caller

# Copy everything from the current directory inside the container
COPY . .

# Build the binary (using go mod) and execute UPX
RUN CGO_ENABLED=0 GOOS=linux \
 go build -a -ldflags '-w -extldflags "-static"' -o /tmp/caller

############################
# STEP 2 build a small image
############################
FROM alpine:3.11.6

# Import from builder.
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
# Copy our static executable
COPY --from=builder /tmp/caller /home/app/caller

# Use the unprivileged user.
USER app

# Run the binary.
ENTRYPOINT ["/home/app/caller"]