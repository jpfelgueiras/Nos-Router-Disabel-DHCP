# Use a lightweight base image
FROM alpine:latest

# Install required packages
RUN apk add --no-cache curl bash jq

# Copy the script into the container
COPY check_and_update.sh /usr/local/bin/check_and_update.sh

# Make the script executable
RUN chmod +x /usr/local/bin/check_and_update.sh

# Set the default command to run the script
CMD ["/usr/local/bin/check_and_update.sh"]
