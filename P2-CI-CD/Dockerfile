# Use lightweight Nginx image
FROM nginx:alpine

# Copy all app files to Nginx html directory
COPY . /usr/share/nginx/html

# Expose container port
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
