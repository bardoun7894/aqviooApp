# Aqvioo Admin Dashboard - Docker Deployment

This guide explains how to build and run the Aqvioo Admin Dashboard using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, but recommended)

## Quick Start

### Option 1: Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

The admin dashboard will be available at: **http://localhost:3000**

### Option 2: Using Docker CLI

```bash
# Build the image
docker build -t aqvioo-admin:latest .

# Run the container
docker run -d \
  --name aqvioo-admin-dashboard \
  -p 3000:80 \
  --restart unless-stopped \
  aqvioo-admin:latest

# View logs
docker logs -f aqvioo-admin-dashboard

# Stop the container
docker stop aqvioo-admin-dashboard

# Remove the container
docker rm aqvioo-admin-dashboard
```

## What the Docker Setup Does

1. **Stage 1 - Build**: Uses official Flutter Docker image to:
   - Install Flutter dependencies
   - Copy source code and .env configuration
   - Build the Flutter web application with release optimizations

2. **Stage 2 - Serve**: Uses lightweight Nginx Alpine image to:
   - Serve the built Flutter web app
   - Handle SPA routing (all routes redirect to index.html)
   - Enable gzip compression for faster loading
   - Cache static assets for 1 year
   - Add security headers

## Configuration

### Environment Variables

The `.env` file contains API keys for:
- OpenAI API
- ElevenLabs API
- Kie API
- Tabby Payment API

This file is included in the Docker image during build.

### Firebase Configuration

Firebase configuration is embedded in:
- `/lib/firebase_options.dart` for Flutter/Dart code
- `/web/index.html` for web platform

## Accessing the Admin Dashboard

1. Open your browser and go to: **http://localhost:3000**
2. You'll be automatically redirected to the admin login page
3. Log in with your admin credentials

### Creating an Admin User

Before you can log in, you need to create an admin user in Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **beldify-b445b**
3. Create a user in Authentication:
   - Email: `mbardouni44@gmail.com`
   - Password: `moha1234`
4. Create an admin document in Firestore:
   ```
   Collection: admins
   Document ID: [use the same UID from Authentication]
   Fields:
   {
     "email": "mbardouni44@gmail.com",
     "displayName": "Admin User",
     "role": "superAdmin",
     "permissions": {
       "canManageUsers": true,
       "canAdjustCredits": true,
       "canModerateContent": true,
       "canViewPayments": true,
       "canManageAdmins": true,
       "canConfigureSettings": true
     },
     "createdAt": [current timestamp]
   }
   ```

## Troubleshooting

### Port Already in Use

If port 3000 is already in use, you can change it:

**Docker Compose:**
Edit `docker-compose.yml` and change the port mapping:
```yaml
ports:
  - "8080:80"  # Change 3000 to any available port
```

**Docker CLI:**
```bash
docker run -d -p 8080:80 aqvioo-admin:latest
```

### Rebuild After Code Changes

```bash
# Stop and remove existing container
docker-compose down

# Rebuild with no cache
docker-compose build --no-cache

# Start again
docker-compose up -d
```

### View Container Logs

```bash
# Using Docker Compose
docker-compose logs -f aqvioo-admin

# Using Docker CLI
docker logs -f aqvioo-admin-dashboard
```

## Production Deployment

For production deployment:

1. Update `.env` with production API keys
2. Update Firebase configuration in `firebase_options.dart` and `web/index.html`
3. Build and push to a container registry:
   ```bash
   docker build -t your-registry/aqvioo-admin:v1.0.0 .
   docker push your-registry/aqvioo-admin:v1.0.0
   ```
4. Deploy to your hosting platform (AWS ECS, Google Cloud Run, Azure Container Instances, etc.)

## Architecture

```
┌─────────────────────────────────────────┐
│  Multi-Stage Docker Build               │
├─────────────────────────────────────────┤
│  Stage 1: Flutter Build                 │
│  - Base: cirruslabs/flutter:stable      │
│  - Installs dependencies                │
│  - Builds optimized web bundle          │
│                                          │
│  Stage 2: Nginx Serve                   │
│  - Base: nginx:alpine (lightweight)     │
│  - Serves static files                  │
│  - Handles SPA routing                  │
│  - Gzip compression                     │
│  - Security headers                     │
└─────────────────────────────────────────┘
         │
         ▼
    Port 3000:80
         │
         ▼
   [Admin Dashboard]
```

## Performance Optimizations

The Docker setup includes:

- **Multi-stage build**: Reduces final image size by ~90%
- **Gzip compression**: Faster page loads
- **Asset caching**: Static files cached for 1 year
- **Tree-shaking**: Only includes used Material Icons
- **Minification**: JavaScript and CSS minified in release build

## Security

The Nginx configuration includes:
- X-Frame-Options: Prevents clickjacking
- X-Content-Type-Options: Prevents MIME type sniffing
- X-XSS-Protection: Enables browser XSS protection

For production:
- Use HTTPS (configure reverse proxy)
- Implement rate limiting
- Add authentication middleware
- Regular security updates
