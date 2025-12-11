# 🚀 QUICK START - DOCKER

## Chạy ngay trong 3 bước!

### Bước 1: Build Maven Project
```bash
mvn clean package -DskipTests
```

### Bước 2: Start Docker
```bash
docker-compose up -d --build
```

### Bước 3: Truy cập
```
http://localhost:8080
```

**Tài khoản mặc định**: 
- Username: `admin`
- Password: `Admin@123`

---

## 🔧 Commands thường dùng

### Start
```bash
docker-compose up -d
```

### Stop
```bash
docker-compose down
```

### Xem logs
```bash
docker-compose logs -f web
```

### Restart
```bash
docker-compose restart
```

### Rebuild (khi có thay đổi code)
```bash
mvn clean package -DskipTests
docker-compose down
docker-compose up -d --build
```

---

## 💾 Data Persistence

### ✅ Data KHÔNG mất khi:
- `docker-compose down` (chỉ stop containers)
- `docker-compose restart`
- `docker-compose up -d --build` (rebuild images)

### ❌ Data MẤT khi:
- `docker-compose down -v` (xóa volumes)
- `docker volume rm` (xóa manual)

---

## 📦 Volumes được mount

| Volume | Mô tả | Persist? |
|--------|-------|----------|
| `mysql_data` | Database MySQL | ✅ Yes |
| `upload_data` | Files upload | ✅ Yes |
| `./logs` | Tomcat logs | ✅ Yes |

---

## 🔍 Kiểm tra trạng thái

```bash
# Xem containers đang chạy
docker-compose ps

# Xem resource usage
docker stats

# Check health
curl http://localhost:8080
```

---

## 💡 Tips

### Connect MySQL từ local
```bash
mysql -h 127.0.0.1 -P 3306 -u warranty_user -pwarranty_pass warranty_system
```

### Backup Database
```bash
docker exec warranty_mysql mysqldump -u warranty_user -pwarranty_pass warranty_system > backup.sql
```

### Restore Database
```bash
docker exec -i warranty_mysql mysql -u warranty_user -pwarranty_pass warranty_system < backup.sql
```

### Exec vào container
```bash
docker exec -it warranty_web bash
docker exec -it warranty_mysql bash
```

---

## 🐛 Troubleshooting

### Port đã được sử dụng?
Sửa port trong `docker-compose.yml`:
```yaml
ports:
  - "8081:8080"  # Web
  - "3307:3306"  # MySQL
```

### MySQL chưa ready?
```bash
docker-compose logs mysql
# Đợi message: "ready for connections"
```

### Web không start?
```bash
docker-compose logs web
# Check lỗi ở logs
```

### Clear everything và start lại
```bash
docker-compose down -v
docker system prune -a
docker-compose up -d --build
```

---

## 📖 Đọc thêm

- **DOCKER_GUIDE.md**: Hướng dẫn chi tiết
- **README.md**: Tổng quan hệ thống
- **DEVELOPMENT_GUIDE.md**: Hướng dẫn phát triển

---

**Happy Coding!** 🎉
