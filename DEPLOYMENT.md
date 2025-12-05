# Aqvioo Admin Dashboard - Deployment Guide

## Docker Image Successfully Created!

Your admin dashboard is now containerized and ready for deployment to any server.

### Image Details

- **Image Name**: `aqvioo-admin:latest`
- **Image Size**: 87.8MB (lightweight!)
- **Base Image**: nginx:alpine
- **Build Method**: Pre-built Flutter web + Nginx

### Currently Running

The container is running locally on: **http://localhost:3000**

Container details:
- Name: `aqvioo-admin`
- Port: `3000:80` (external:internal)
- Restart policy: `unless-stopped`
- Health check: Enabled (30s interval)

---

## Quick Commands

### Local Development

```bash
# Check container status
docker ps | grep aqvioo-admin

# View logs
docker logs -f aqvioo-admin

# Stop container
docker stop aqvioo-admin

# Start container
docker start aqvioo-admin

# Remove container
docker rm -f aqvioo-admin

# Rebuild and restart
flutter build web --release
docker build -f Dockerfile.simple -t aqvioo-admin:latest .
docker rm -f aqvioo-admin
docker run -d -p 3000:80 --name aqvioo-admin --restart unless-stopped aqvioo-admin:latest
```

---

## Deploying to Other Servers

### Option 1: Export/Import Docker Image (No Registry)

**On your local machine:**
```bash
# Save image to a tar file
docker save aqvioo-admin:latest -o aqvioo-admin.tar

# Compress for faster transfer (optional)
gzip aqvioo-admin.tar
```

**Transfer to server (choose one):**
```bash
# Via SCP
scp aqvioo-admin.tar.gz user@your-server:/path/to/

# Via rsync
rsync -avz aqvioo-admin.tar.gz user@your-server:/path/to/
```

**On the server:**
```bash
# Decompress (if compressed)
gunzip aqvioo-admin.tar.gz

# Load image
docker load -i aqvioo-admin.tar

# Run container
docker run -d \
  -p 3000:80 \
  --name aqvioo-admin \
  --restart unless-stopped \
  aqvioo-admin:latest
```

### Option 2: Using Docker Hub (Public/Private Registry)

**Push to Docker Hub:**
```bash
# Login to Docker Hub
docker login

# Tag image with your username
docker tag aqvioo-admin:latest YOUR_USERNAME/aqvioo-admin:latest

# Push to Docker Hub
docker push YOUR_USERNAME/aqvioo-admin:latest
```

**On the server:**
```bash
# Pull from Docker Hub
docker pull YOUR_USERNAME/aqvioo-admin:latest

# Run container
docker run -d \
  -p 3000:80 \
  --name aqvioo-admin \
  --restart unless-stopped \
  YOUR_USERNAME/aqvioo-admin:latest
```

### Option 3: Using Private Registry (AWS ECR, Google GCR, etc.)

**AWS ECR Example:**
```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository (first time only)
aws ecr create-repository --repository-name aqvioo-admin --region us-east-1

# Tag image
docker tag aqvioo-admin:latest YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/aqvioo-admin:latest

# Push to ECR
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/aqvioo-admin:latest
```

**On the server:**
```bash
# Authenticate
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# Pull and run
docker pull YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/aqvioo-admin:latest
docker run -d \
  -p 3000:80 \
  --name aqvioo-admin \
  --restart unless-stopped \
  YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/aqvioo-admin:latest
```

---

## Production Deployment

### Using Docker Compose (Recommended)

Create `docker-compose.prod.yml`:
```yaml
version: '3.8'

services:
  aqvioo-admin:
    image: aqvioo-admin:latest
    container_name: aqvioo-admin
    ports:
      - "80:80"  # or "443:443" with SSL
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
    labels:
      - "com.aqvioo.description=Aqvioo Admin Dashboard"
      - "com.aqvioo.version=1.0.0"
```

Deploy:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### With Nginx Reverse Proxy + SSL

Create `nginx.conf`:
```nginx
server {
    listen 80;
    server_name admin.aqvioo.com;

    # Redirect to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name admin.aqvioo.com;

    ssl_certificate /etc/letsencrypt/live/admin.aqvioo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/admin.aqvioo.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Platform-Specific Deployment

### AWS ECS (Elastic Container Service)

1. Push image to ECR (see Option 3 above)
2. Create ECS task definition:
```json
{
  "family": "aqvioo-admin",
  "containerDefinitions": [
    {
      "name": "aqvioo-admin",
      "image": "YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/aqvioo-admin:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "memory": 512,
      "cpu": 256
    }
  ]
}
```
3. Create ECS service
4. Configure Application Load Balancer

### Google Cloud Run

```bash
# Tag for GCR
docker tag aqvioo-admin:latest gcr.io/YOUR_PROJECT/aqvioo-admin:latest

# Push to GCR
docker push gcr.io/YOUR_PROJECT/aqvioo-admin:latest

# Deploy to Cloud Run
gcloud run deploy aqvioo-admin \
  --image gcr.io/YOUR_PROJECT/aqvioo-admin:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 80
```

### Azure Container Instances

```bash
# Tag for ACR
docker tag aqvioo-admin:latest yourregistry.azurecr.io/aqvioo-admin:latest

# Push to ACR
docker push yourregistry.azurecr.io/aqvioo-admin:latest

# Deploy to ACI
az container create \
  --resource-group aqvioo-rg \
  --name aqvioo-admin \
  --image yourregistry.azurecr.io/aqvioo-admin:latest \
  --dns-name-label aqvioo-admin \
  --ports 80
```

### DigitalOcean App Platform

```bash
# Push to DigitalOcean Container Registry
docker tag aqvioo-admin:latest registry.digitalocean.com/YOUR_REGISTRY/aqvioo-admin:latest
docker push registry.digitalocean.com/YOUR_REGISTRY/aqvioo-admin:latest

# Deploy via App Platform UI or doctl
doctl apps create --spec app.yaml
```

### Kubernetes (K8s)

Create `deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aqvioo-admin
spec:
  replicas: 2
  selector:
    matchLabels:
      app: aqvioo-admin
  template:
    metadata:
      labels:
        app: aqvioo-admin
    spec:
      containers:
      - name: aqvioo-admin
        image: aqvioo-admin:latest
        ports:
        - containerPort: 80
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: aqvioo-admin-service
spec:
  selector:
    app: aqvioo-admin
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

Deploy:
```bash
kubectl apply -f deployment.yaml
```

---

## Environment Variables & Configuration

### Updating API Keys

To update API keys without rebuilding:

1. **Create .env file on server**
2. **Mount as volume:**
```bash
docker run -d \
  -p 3000:80 \
  -v $(pwd)/.env:/usr/share/nginx/html/.env:ro \
  --name aqvioo-admin \
  --restart unless-stopped \
  aqvioo-admin:latest
```

### Firebase Configuration

Firebase config is baked into the image. To update:
1. Edit `lib/firebase_options.dart` and `web/index.html`
2. Rebuild: `flutter build web --release`
3. Rebuild Docker image: `docker build -f Dockerfile.simple -t aqvioo-admin:latest .`
4. Redeploy

---

## Monitoring & Logs

### View Container Logs
```bash
# Real-time logs
docker logs -f aqvioo-admin

# Last 100 lines
docker logs --tail 100 aqvioo-admin

# Logs with timestamps
docker logs -t aqvioo-admin
```

### Health Check
```bash
# Check health status
docker inspect --format='{{.State.Health.Status}}' aqvioo-admin

# Manual health check
curl http://localhost:3000/
```

### Resource Usage
```bash
# Container stats
docker stats aqvioo-admin

# Disk usage
docker system df
```

---

## Scaling

### Horizontal Scaling with Docker Compose

```yaml
version: '3.8'

services:
  aqvioo-admin:
    image: aqvioo-admin:latest
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    restart: unless-stopped

  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-lb.conf:/etc/nginx/nginx.conf
    depends_on:
      - aqvioo-admin
```

### Auto-scaling (Cloud Platforms)

- **AWS ECS**: Configure Auto Scaling with target tracking
- **Google Cloud Run**: Automatic based on traffic
- **Kubernetes**: HorizontalPodAutoscaler (HPA)

---

## Backup & Recovery

### Backup Docker Image
```bash
# Save image
docker save aqvioo-admin:latest | gzip > aqvioo-admin-backup-$(date +%Y%m%d).tar.gz
```

### Restore
```bash
docker load < aqvioo-admin-backup-20251201.tar.gz
```

---

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs aqvioo-admin

# Check if port is available
lsof -i :3000

# Remove and recreate
docker rm -f aqvioo-admin
docker run -d -p 3000:80 --name aqvioo-admin aqvioo-admin:latest
```

### White page / Firebase errors
- Ensure Firebase config is correct in `firebase_options.dart` and `web/index.html`
- Check browser console for errors
- Verify `.env` file is present

### Permission denied errors
- Ensure proper file permissions in `build/web`
- Check SELinux/AppArmor settings on server

---

## Security Best Practices

1. **Use HTTPS**: Always use SSL/TLS in production
2. **Firewall**: Only expose necessary ports
3. **Updates**: Regularly update base image (`docker pull nginx:alpine`)
4. **Secrets**: Never commit API keys to version control
5. **Access Control**: Implement IP whitelist or VPN for admin panel
6. **Monitoring**: Set up log aggregation and monitoring

---

## Cost Optimization

- **Image Size**: 87.8MB (already optimized with nginx:alpine)
- **Resource Limits**: Set appropriate CPU/memory limits
- **Caching**: Leverage nginx caching for static assets
- **CDN**: Use CloudFlare/CloudFront for global distribution

---

## Support & Documentation

- Docker Documentation: https://docs.docker.com/
- Nginx Documentation: https://nginx.org/en/docs/
- Flutter Web Documentation: https://docs.flutter.dev/platform-integration/web
- Firebase Documentation: https://firebase.google.com/docs

---

## Next Steps

1. ✅ Docker image created and running
2. Test locally at http://localhost:3000
3. Create Firebase admin user (see main README)
4. Choose deployment method (export/import or registry)
5. Deploy to production server
6. Configure domain and SSL
7. Set up monitoring and backups
8. Document any environment-specific configurations
