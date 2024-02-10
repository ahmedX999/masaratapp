# Use the official Flutter image as the base image
FROM cirrusci/flutter:latest AS build

# Set environment variables for Flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Set the working directory in the container
WORKDIR /app

# Copy the pubspec.yaml and pubspec.lock files to the container
COPY pubspec.* ./

# Install dependencies
RUN flutter pub get

# Copy the entire project to the container
COPY . .

# Build the Flutter app for the web
RUN flutter build web --release

# Stage 2: Serve the web assets using NGINX
FROM nginx:alpine

# Copy the built web assets from the previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
