#!/bin/bash

# ===========================================
# Script để build và deploy Docker
# ===========================================

echo "====================================="
echo "Warranty Management System - Docker Build"
echo "====================================="

# Build Docker images với Maven build bên trong
echo ""
echo "Building Docker images (Maven build included)..."
docker-compose build --no-cache

if [ $? -ne 0 ]; then
    echo "ERROR: Docker build failed!"
    exit 1
fi

# Stop và remove containers cũ (nếu có)
echo ""
echo "Stopping old containers..."
docker-compose down

# Start containers
echo ""
echo "Starting containers..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start containers!"
    exit 1
fi

# Wait for services to be ready
echo ""
echo "Waiting for services to be ready..."
echo "Waiting for MySQL..."
sleep 10

echo "Waiting for Tomcat..."
sleep 15

# Bước 6: Check status
echo ""
echo "Step 6: Checking container status..."
docker-compose ps

# Bước 7: Show logs
echo ""
echo "====================================="
echo "Deployment completed!"
echo "====================================="
echo ""
echo "Application URL: http://localhost:8080"
echo ""
echo "MySQL Connection:"
echo "  Host: localhost"
echo "  Port: 3306"
echo "  Database: warranty_system"
echo "  Username: warranty_user"
echo "  Password: warranty_pass"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f web"
echo "  docker-compose logs -f mysql"
echo ""
echo "To stop:"
echo "  docker-compose down"
echo ""
echo "To restart:"
echo "  docker-compose restart"
echo ""
