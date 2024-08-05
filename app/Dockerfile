# Use the base image of Alpine
FROM alpine:latest

# Install essential dependencies, and remove cache and unnecessary files
RUN apk --no-cache add \
    git \
    curl \
    bash \
    docker-cli \
    docker-compose && \
    rm -rf /var/cache/apk/* /tmp/*

# Copy the deployment script to the container
COPY bulckan.sh /usr/local/bin/bulckan.sh

# Give execution permissions to the script
RUN chmod +x /usr/local/bin/bulckan.sh

ENTRYPOINT ["/usr/local/bin/bulckan.sh"]