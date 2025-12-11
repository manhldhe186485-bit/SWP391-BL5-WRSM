# HƯỚNG DẪN SỬ DỤNG DOCKER

## Giới thiệu

Hệ thống được containerized với Docker để dễ dàng deploy và scale. Sử dụng Docker Compose để quản lý multiple containers.

## Yêu cầu

- Docker Desktop (Windows/Mac) hoặc Docker Engine (Linux)
- Docker Compose v3.8+
- 4GB RAM tối thiểu
- 10GB disk space

## Cấu trúc Docker

### Services:

1. **mysql**: MySQL 8.0 database
   - Port: 3306
   - Volume: `mysql_data` (persist database)
   - Auto-init với schema.sql

2. **web**: Tomcat 9.0 + Java 11
   - Port: 8080
   - Volume: `upload_data` (persist uploaded files)
   - Depends on: mysql

### Volumes:

- `mysql_data`: Lưu trữ database MySQL
- `upload_data`: Lưu trữ files upload
- `./logs`: Mount logs của Tomcat

## Cách sử dụng

### 1. Build và Start (Lần đầu tiên)

#### Windows:
```bash
docker-build.bat
```

#### Linux/Mac:
```bash
chmod +x docker-build.sh
./docker-build.sh
```

#### Hoặc manual:
```bash
# Build Maven project
mvn clean package -DskipTests

# Start Docker containers
docker-compose up -d --build
```

### 2. Truy cập Application

Mở trình duyệt và truy cập:
```
http://localhost:8080
```

### 3. Xem Logs

```bash
# Xem logs của web container
docker-compose logs -f web

# Xem logs của MySQL
docker-compose logs -f mysql

# Xem logs của tất cả services
docker-compose logs -f
```

### 4. Stop Containers

```bash
docker-compose down
```

**LƯU Ý**: Lệnh này CHỈ stop containers, KHÔNG xóa data trong volumes!

### 5. Restart Containers

```bash
docker-compose restart

# Hoặc restart từng service
docker-compose restart web
docker-compose restart mysql
```

### 6. Rebuild và Deploy lại

```bash
# Stop containers
docker-compose down

# Rebuild images
docker-compose build --no-cache

# Start lại
docker-compose up -d
```

**QUAN TRỌNG**: Database data KHÔNG bị mất khi rebuild!

## Quản lý Data

### Volumes được mount:

1. **mysql_data**: 
   - Chứa toàn bộ database MySQL
   - Persist khi rebuild/restart containers
   - Location: Docker managed volume

2. **upload_data**:
   - Chứa files upload từ users
   - Persist khi rebuild/restart containers
   - Location: Docker managed volume

3. **logs**:
   - Tomcat logs
   - Location: `./logs` (local folder)

### Xem volumes:

```bash
docker volume ls
```

### Backup Database:

```bash
# Backup
docker exec warranty_mysql mysqldump -u warranty_user -pwarranty_pass warranty_system > backup.sql

# Restore
docker exec -i warranty_mysql mysql -u warranty_user -pwarranty_pass warranty_system < backup.sql
```

### Xóa volumes (XÓA TOÀN BỘ DATA):

```bash
# Stop containers
docker-compose down

# Xóa volumes
docker-compose down -v

# Hoặc xóa specific volume
docker volume rm warranty_management_system_mysql_data
```

## Kết nối MySQL từ Local

```bash
# Từ MySQL Client
mysql -h 127.0.0.1 -P 3306 -u warranty_user -p
# Password: warranty_pass

# Từ MySQL Workbench
Host: 127.0.0.1
Port: 3306
Username: warranty_user
Password: warranty_pass
Database: warranty_system
```

## Troubleshooting

### 1. Port đã được sử dụng

Nếu port 8080 hoặc 3306 đã được sử dụng, sửa trong `docker-compose.yml`:

```yaml
ports:
  - "8081:8080"  # Thay 8080 thành port khác
```

### 2. Container không start

```bash
# Xem logs để debug
docker-compose logs web
docker-compose logs mysql

# Check status
docker-compose ps
```

### 3. Database connection failed

```bash
# Kiểm tra MySQL đã ready chưa
docker-compose logs mysql | grep "ready for connections"

# Restart MySQL
docker-compose restart mysql

# Wait thêm time
sleep 20
```

### 4. Out of memory

Tăng memory limit trong `docker-compose.yml`:

```yaml
services:
  web:
    deploy:
      resources:
        limits:
          memory: 2G
```

### 5. Rebuild không pick up changes

```bash
# Force rebuild không cache
docker-compose build --no-cache

# Remove old images
docker-compose down --rmi all

# Rebuild
docker-compose up -d --build
```

## Production Deployment

### 1. Thay đổi passwords

Sửa trong `docker-compose.yml`:
```yaml
environment:
  MYSQL_ROOT_PASSWORD: <strong-password>
  MYSQL_PASSWORD: <strong-password>
```

### 2. Sử dụng environment file

Tạo file `.env`:
```
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_PASSWORD=your_password
```

### 3. Enable SSL cho MySQL

Thêm vào `docker-compose.yml`:
```yaml
volumes:
  - ./ssl:/etc/mysql/ssl
command: --require_secure_transport=ON
```

### 4. Reverse Proxy (Nginx)

Thêm service nginx:
```yaml
nginx:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf
```

## Commands Hữu ích

```bash
# Xem resource usage
docker stats

# Exec vào container
docker exec -it warranty_web bash
docker exec -it warranty_mysql bash

# Copy files từ container
docker cp warranty_web:/usr/local/tomcat/logs ./logs

# Xem networks
docker network ls

# Inspect container
docker inspect warranty_web

# Prune unused data
docker system prune -a
```

## Update Application

### Quick Update (chỉ update code):
```bash
mvn clean package -DskipTests
docker-compose restart web
```

### Full Update (update cả dependencies):
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Monitoring

### Health Checks

```bash
# Check health status
docker-compose ps

# Manual health check
curl http://localhost:8080/
```

### Logs Monitoring

```bash
# Real-time logs
docker-compose logs -f --tail=100

# Export logs
docker-compose logs > application.log
```

## Backup Strategy

### Daily Backup Script (Linux/Mac):

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec warranty_mysql mysqldump -u warranty_user -pwarranty_pass warranty_system > backup_$DATE.sql
find . -name "backup_*.sql" -mtime +7 -delete
```

### Restore from Backup:

```bash
docker exec -i warranty_mysql mysql -u warranty_user -pwarranty_pass warranty_system < backup_20241210.sql
```

## Performance Tuning

### MySQL Configuration

Tạo file `my.cnf`:
```ini
[mysqld]
max_connections=200
innodb_buffer_pool_size=1G
innodb_log_file_size=256M
```

Mount vào container:
```yaml
volumes:
  - ./my.cnf:/etc/mysql/conf.d/my.cnf
```

### Tomcat Configuration

Thêm JAVA_OPTS trong Dockerfile:
```dockerfile
ENV JAVA_OPTS="-Xms512m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m"
```

---

**Liên hệ hỗ trợ**: Nếu gặp vấn đề, tạo issue trên GitHub hoặc liên hệ admin.
