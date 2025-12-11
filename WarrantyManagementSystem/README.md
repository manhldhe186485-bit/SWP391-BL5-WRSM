# Hệ Thống Quản Lý Bảo Hành Thiết Bị Điện Tử

## Mô tả Dự án

Đây là một hệ thống quản lý bảo hành thiết bị điện tử được xây dựng bằng Java, JSP, và Servlet. Hệ thống cho phép quản lý toàn bộ quy trình bảo hành từ lúc tiếp nhận, phân công kỹ thuật viên, sửa chữa, quản lý kho linh kiện, đến khi giao hàng cho khách hàng.

## Tính năng chính

### 1. Quản lý Người dùng (Admin)
- Import dữ liệu khách hàng và sản phẩm từ Excel
- Quản lý danh sách sản phẩm đã bán
- Quản lý người dùng hệ thống
- Xem báo cáo và thống kê

### 2. Kỹ thuật viên (Technician)
- Tiếp nhận thiết bị từ khách hàng
- Tạo phiếu tiếp nhận bảo hành/sửa chữa
- Kiểm tra và chẩn đoán sự cố
- Tạo phiếu yêu cầu linh kiện
- Cập nhật tiến trình sửa chữa
- Hoàn thành và bàn giao sản phẩm

### 3. Quản lý Kỹ thuật (Technical Manager)
- Xem dashboard các phiếu chờ xử lý
- Phân công kỹ thuật viên cho từng phiếu bảo hành
- Theo dõi tiến độ công việc
- Quản lý đội ngũ kỹ thuật viên

### 4. Quản lý Kho (Warehouse)
- Quản lý tồn kho linh kiện
- Xử lý yêu cầu xuất linh kiện
- Cập nhật số lượng linh kiện
- Theo dõi lịch sử xuất nhập

### 5. Khách hàng (Customer)
- Đăng ký tài khoản
- Tra cứu tình trạng đơn bảo hành
- Xem lịch sử sửa chữa
- Nhận thông báo cập nhật

## Công nghệ sử dụng

- **Backend**: Java 11, Servlet API 4.0
- **Frontend**: JSP, HTML5, CSS3, JavaScript
- **Database**: MySQL 8.0
- **Build Tool**: Maven
- **Server**: Apache Tomcat 9.0+
- **Libraries**:
  - Apache POI (Xử lý Excel)
  - BCrypt (Mã hóa mật khẩu)
  - JSTL (JSP Standard Tag Library)
  - MySQL Connector
  - iText (Tạo PDF)
  - Gson (JSON processing)

## Cấu trúc Project

```
WarrantyManagementSystem/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/warranty/
│   │   │       ├── model/          # Entity classes
│   │   │       ├── dao/            # Data Access Objects
│   │   │       ├── servlet/        # Servlet controllers
│   │   │       ├── filter/         # Filters (Auth, Encoding)
│   │   │       └── util/           # Utility classes
│   │   ├── resources/
│   │   │   ├── database.properties
│   │   │   └── mail.properties
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   └── web.xml
│   │       ├── views/              # JSP pages
│   │       ├── css/                # Stylesheets
│   │       ├── js/                 # JavaScript files
│   │       ├── uploads/            # Uploaded files
│   │       ├── index.jsp
│   │       └── login.jsp
├── database/
│   └── schema.sql                  # Database schema
├── pom.xml                         # Maven configuration
└── README.md
```

## Hướng dẫn Cài đặt

### Có 2 cách cài đặt:

#### 🐳 Cách 1: Sử dụng Docker (KHUYẾN NGHỊ - Dễ nhất!)

**Xem**: [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md)

```bash
# Build project
mvn clean package -DskipTests

# Start với Docker
docker-compose up -d --build

# Truy cập
http://localhost:8080
```

**Ưu điểm**:
- ✅ Cài đặt trong 3 bước
- ✅ Không cần cài MySQL, Tomcat riêng
- ✅ Database tự động khởi tạo
- ✅ Data không mất khi rebuild
- ✅ Dễ deploy lên server

---

#### 💻 Cách 2: Cài đặt thủ công (Traditional)

### 1. Yêu cầu Hệ thống

- JDK 11 trở lên
- Apache Tomcat 9.0+
- MySQL 8.0+
- Maven 3.6+
- IDE: IntelliJ IDEA, Eclipse, hoặc VS Code

### 2. Cài đặt Database

```sql
# Tạo database
mysql -u root -p

# Chạy script tạo database và tables
source database/schema.sql
```

Hoặc copy nội dung file `database/schema.sql` và chạy trong MySQL Workbench.

### 3. Cấu hình Database

Mở file `src/main/resources/database.properties` và cập nhật thông tin:

```properties
db.url=jdbc:mysql://localhost:3306/warranty_system?useSSL=false&serverTimezone=UTC
db.username=root
db.password=your_password
db.driver=com.mysql.cj.jdbc.Driver
```

### 4. Build Project

```bash
# Di chuyển vào thư mục project
cd WarrantyManagementSystem

# Build với Maven
mvn clean install
```

### 5. Deploy lên Tomcat

#### Cách 1: Deploy từ IDE
- Import project vào IDE
- Cấu hình Tomcat server trong IDE
- Run/Debug project

#### Cách 2: Deploy thủ công
```bash
# Copy file WAR vào thư mục webapps của Tomcat
cp target/warranty-system.war /path/to/tomcat/webapps/

# Start Tomcat
cd /path/to/tomcat/bin
./catalina.sh run     # Linux/Mac
catalina.bat run      # Windows
```

### 6. Truy cập Hệ thống

Mở trình duyệt và truy cập:
```
http://localhost:8080/warranty-system/
```

## Tài khoản Mặc định

Sau khi chạy script database, hệ thống sẽ có các tài khoản mặc định:

| Username    | Password      | Role          |
|-------------|---------------|---------------|
| admin       | Admin@123     | ADMIN         |
| techmanager | Manager@123   | TECH_MANAGER  |
| tech01      | Tech@123      | TECHNICIAN    |
| warehouse   | Warehouse@123 | WAREHOUSE     |

**Lưu ý**: Nên thay đổi mật khẩu sau lần đăng nhập đầu tiên.

## Hướng dẫn Sử dụng

### Import Dữ liệu từ Excel

1. Đăng nhập với tài khoản Admin
2. Vào menu "Import Excel"
3. Chuẩn bị file Excel với cấu trúc:
   - Sheet 1: Thông tin sản phẩm
   - Cột: Serial Number | Product Code | Product Name | Customer Name | Phone | Purchase Date | Warranty Months

4. Chọn file và upload
5. Hệ thống sẽ tự động import và tạo records

### Quy trình Bảo hành

1. **Khách hàng đến** → Gặp Technician bất kỳ
2. **Technician kiểm tra** → Tạo Phiếu Tiếp nhận
3. **Tech Manager** → Xem task mới → Assign cho Technician
4. **Technician được assign** → Chẩn đoán và sửa chữa
5. **Cần linh kiện** → Tạo Parts Request → Warehouse xử lý
6. **Cập nhật tiến trình** → Khách hàng xem trên Portal
7. **Hoàn thành** → Thông báo khách hàng → Bàn giao

## Database Schema

### Các bảng chính:

- **users**: Người dùng hệ thống
- **customers**: Thông tin khách hàng
- **products**: Danh mục sản phẩm
- **product_serials**: Sản phẩm đã bán (có serial)
- **repair_tickets**: Phiếu bảo hành/sửa chữa
- **repair_sheets**: Chi tiết sửa chữa
- **inventory_items**: Kho linh kiện
- **parts_requests**: Yêu cầu xuất linh kiện
- **parts_request_items**: Chi tiết linh kiện trong yêu cầu
- **repair_progress_logs**: Nhật ký tiến trình
- **notifications**: Thông báo
- **audit_logs**: Nhật ký kiểm toán

## API Endpoints (Servlets)

### Authentication
- `POST /login` - Đăng nhập
- `GET /logout` - Đăng xuất
- `POST /register` - Đăng ký (Customer)

### Admin
- `GET/POST /admin/import-excel` - Import Excel
- `GET /admin/product-customer-list` - Danh sách sản phẩm

### Technician
- `GET/POST /technician/create-intake-ticket` - Tạo phiếu tiếp nhận
- `GET /technician/dashboard` - Dashboard kỹ thuật viên
- `POST /technician/update-progress` - Cập nhật tiến trình
- `POST /technician/create-parts-request` - Yêu cầu linh kiện

### Tech Manager
- `GET /tech-manager/dashboard` - Dashboard quản lý
- `POST /tech-manager/assign-ticket` - Phân công task

### Warehouse
- `GET /warehouse/dashboard` - Dashboard kho
- `POST /warehouse/process-request` - Xử lý yêu cầu linh kiện
- `GET/POST /warehouse/inventory` - Quản lý tồn kho

### Customer Portal
- `GET /customer/track-ticket` - Tra cứu đơn hàng

## Tính năng Bổ sung (TODO)

- [ ] Email notifications
- [ ] PDF report generation
- [ ] SMS notifications
- [ ] Advanced search and filters
- [ ] Analytics dashboard
- [ ] Mobile responsive design
- [ ] REST API for mobile app
- [ ] Real-time notifications (WebSocket)
- [ ] Barcode/QR code scanning
- [ ] Multi-language support

## Troubleshooting

### Lỗi kết nối Database
```
Kiểm tra:
1. MySQL service đang chạy
2. Thông tin kết nối trong database.properties
3. MySQL user có quyền truy cập
```

### Lỗi 404 Not Found
```
Kiểm tra:
1. Context path trong URL
2. Servlet mapping trong web.xml
3. Tomcat deployment thành công
```

### Lỗi Upload File
```
Kiểm tra:
1. Thư mục uploads/ có quyền write
2. File size không vượt quá giới hạn
3. Thư viện commons-fileupload đã được thêm
```

## Đóng góp

Để đóng góp vào dự án:
1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## Liên hệ

Nếu có câu hỏi hoặc vấn đề, vui lòng tạo Issue trên GitHub.

## License

Dự án này được phát hành dưới giấy phép MIT License.

---

**Phát triển bởi**: Warranty Management Team
**Version**: 1.0.0
**Ngày cập nhật**: December 2025
