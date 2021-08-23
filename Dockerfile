FROM golang:1.16-alpine as build

# Set the working directory
WORKDIR /go/src/app

# Cache dependencies
COPY ["go.mod", "go.sum", "./"]

# Controls the source of Go module downloads
# Can help assure builds are deterministic and secure.
ENV GOPROXY=https://proxy.golang.org

RUN ["go", "get", "-d", "-v", "./..."]
RUN ["go", "install", "-v", "./..."]

# Copy project files
COPY . .

# Build binary file
RUN ["go", "build", "-o", "build/igbot"]

#
# Development build
#
FROM build as dev

# Run the application via Go
CMD ["go", "run", "."]

#
# Production build
#
FROM alpine:3.14.1 as prod

# By default, Docker runs container as root which inside of the container can pose as a security issue.
RUN addgroup -S app && adduser -S -G app app
USER app

# Set the working directory
WORKDIR /home/app/

COPY --from=build /go/src/app/build/igbot ./

# Execute the binary file
CMD ["./igbot"]