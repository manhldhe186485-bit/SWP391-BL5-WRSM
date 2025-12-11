# Makefile for Warranty Management System

.PHONY: help build start stop restart logs clean backup restore

help:
	@echo "Warranty Management System - Docker Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make build      - Build Maven project and Docker images"
	@echo "  make start      - Start all containers"
	@echo "  make stop       - Stop all containers"
	@echo "  make restart    - Restart all containers"
	@echo "  make logs       - Show logs (web)"
	@echo "  make logs-all   - Show all logs"
	@echo "  make logs-mysql - Show MySQL logs"
	@echo "  make ps         - Show running containers"
	@echo "  make clean      - Stop and remove containers (keep volumes)"
	@echo "  make clean-all  - Stop and remove everything (including volumes)"
	@echo "  make backup     - Backup MySQL database"
	@echo "  make restore    - Restore MySQL database from backup.sql"
	@echo "  make shell-web  - Open shell in web container"
	@echo "  make shell-db   - Open shell in MySQL container"
	@echo ""

build:
	@echo "Building Maven project..."
	mvn clean package -DskipTests
	@echo "Building Docker images..."
	docker-compose build --no-cache
	@echo "Build completed!"

start:
	@echo "Starting containers..."
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 20
	@echo "Services started!"
	@echo "Application: http://localhost:8080"

stop:
	@echo "Stopping containers..."
	docker-compose down
	@echo "Containers stopped!"

restart:
	@echo "Restarting containers..."
	docker-compose restart
	@echo "Containers restarted!"

logs:
	docker-compose logs -f web

logs-all:
	docker-compose logs -f

logs-mysql:
	docker-compose logs -f mysql

ps:
	docker-compose ps

clean:
	@echo "Stopping and removing containers (keeping volumes)..."
	docker-compose down
	@echo "Cleanup completed!"

clean-all:
	@echo "WARNING: This will delete all data including database!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All data removed!"; \
	fi

backup:
	@echo "Backing up database..."
	@mkdir -p backups
	docker exec warranty_mysql mysqldump -u warranty_user -pwarranty_pass warranty_system > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup completed!"
	@echo "Backup file: backups/backup_$(shell date +%Y%m%d_%H%M%S).sql"

restore:
	@echo "Restoring database from backup.sql..."
	@if [ ! -f backup.sql ]; then \
		echo "Error: backup.sql not found!"; \
		exit 1; \
	fi
	docker exec -i warranty_mysql mysql -u warranty_user -pwarranty_pass warranty_system < backup.sql
	@echo "Restore completed!"

shell-web:
	docker exec -it warranty_web bash

shell-db:
	docker exec -it warranty_mysql bash

# Development shortcuts
dev-build:
	mvn clean package -DskipTests
	docker-compose restart web

dev-logs:
	docker-compose logs -f --tail=100 web

dev-test:
	curl -I http://localhost:8080

# Production deployment
deploy:
	@echo "Deploying to production..."
	mvn clean package -DskipTests
	docker-compose down
	docker-compose up -d --build
	@echo "Deployment completed!"
	@make ps
