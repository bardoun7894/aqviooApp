# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency definitions
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy project files
COPY . .

# Build the web application
# Uses --web-renderer html can be safer for compatibility, or canvaskit for performance.
# Auto is usually best, but for admin panels HTML is often lighter/sufficient.
# However, for Rive/creative apps, CanvasKit is preferred.
# Defaulting to auto (default behavior).
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
