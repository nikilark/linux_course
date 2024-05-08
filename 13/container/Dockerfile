# Use the Alpine base image
FROM alpine:latest

# Update the package repository and install Nginx
RUN apk update && \
    apk add nginx bash

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Set the working directory
WORKDIR /app

# Copy the static website files
COPY www www

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

# Can be run with docker run -p 8080:80 -d <image_name>