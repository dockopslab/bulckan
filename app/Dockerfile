# Use the base image of Alpine
FROM alpine:latest

# Avoid interactions during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential dependencies
RUN apk update && \
    apk add --no-cache \
    git \
    curl \
    docker \
    bash \
    docker-compose

# Copy the deployment script to the container
COPY bulckan.sh /usr/local/bin/bulckan.sh

# Give execution permissions to the script
RUN chmod +x /usr/local/bin/bulckan.sh

ENTRYPOINT ["/usr/local/bin/bulckan.sh"]