#!/bin/bash

# ===========================================
# One-Click Setup Script
# Cài đặt và chạy hệ thống trong 1 lệnh
# ===========================================

set -e  # Exit on error

echo "========================================="
echo "Warranty Management System - Setup"
echo "========================================="
echo ""

# Check Docker
echo "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo "✅ Docker found"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    exit 1
fi
echo "✅ Docker Compose found"

# Check Maven
echo ""
echo "Checking Maven installation..."
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed!"
    echo "Please install Maven from: https://maven.apache.org/download.cgi"
    exit 1
fi
echo "✅ Maven found"

# Check if already running
echo ""
echo "Checking existing containers..."
if docker ps -a | grep -q warranty_; then
    echo "⚠️  Found existing containers!"
    read -p "Do you want to remove them and start fresh? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing old containers..."
        docker-compose down -v
    else
        echo "Keeping existing containers. Please run 'docker-compose down' manually if needed."
        exit 0
    fi
fi

# Create .env file if not exists
echo ""
echo "Setting up environment..."
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file and set your passwords!"
    echo "Default passwords are used for now."
fi

# Build Maven project
echo ""
echo "========================================="
echo "Step 1: Building Maven project..."
echo "========================================="
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "❌ Maven build failed!"
    exit 1
fi
echo "✅ Maven build successful"

# Build Docker images
echo ""
echo "========================================="
echo "Step 2: Building Docker images..."
echo "========================================="
docker-compose build --no-cache
if [ $? -ne 0 ]; then
    echo "❌ Docker build failed!"
    exit 1
fi
echo "✅ Docker images built"

# Start containers
echo ""
echo "========================================="
echo "Step 3: Starting containers..."
echo "========================================="
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "❌ Failed to start containers!"
    exit 1
fi

# Wait for services
echo ""
echo "Waiting for services to start..."
echo "- MySQL: Starting..."
sleep 10
echo "- MySQL: Initializing database..."
sleep 10
echo "- Tomcat: Starting..."
sleep 10
echo "- Application: Deploying..."
sleep 10

# Check status
echo ""
echo "========================================="
echo "Checking container status..."
echo "========================================="
docker-compose ps

# Health check
echo ""
echo "Performing health checks..."
for i in {1..10}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|302"; then
        echo "✅ Application is UP!"
        break
    else
        if [ $i -eq 10 ]; then
            echo "⚠️  Application might not be ready yet"
            echo "Please check logs: docker-compose logs -f web"
        else
            echo "Waiting... ($i/10)"
            sleep 5
        fi
    fi
done

# Show logs
echo ""
echo "========================================="
echo "Recent logs:"
echo "========================================="
docker-compose logs --tail=20

echo ""
echo "========================================="
echo "✅ SETUP COMPLETED!"
echo "========================================="
echo ""
echo "🌐 Application URL:"
echo "   http://localhost:8080"
echo ""
echo "👤 Default Login:"
echo "   Username: admin"
echo "   Password: Admin@123"
echo ""
echo "💾 MySQL Connection:"
echo "   Host: localhost"
echo "   Port: 3306"
echo "   Database: warranty_system"
echo "   Username: warranty_user"
echo "   Password: warranty_pass"
echo ""
echo "📊 Useful Commands:"
echo "   View logs:     docker-compose logs -f"
echo "   Stop:          docker-compose down"
echo "   Restart:       docker-compose restart"
echo "   Status:        docker-compose ps"
echo ""
echo "📖 Documentation:"
echo "   Quick Start:   DOCKER_QUICKSTART.md"
echo "   Full Guide:    DOCKER_GUIDE.md"
echo "   Development:   DEVELOPMENT_GUIDE.md"
echo ""
echo "Happy coding! 🚀"
