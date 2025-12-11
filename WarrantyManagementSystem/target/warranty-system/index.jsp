<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ - Hệ thống Bảo hành</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        .navbar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .navbar h1 {
            font-size: 24px;
        }
        .navbar .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .navbar a {
            color: white;
            text-decoration: none;
            padding: 8px 15px;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .navbar a:hover {
            background: rgba(255,255,255,0.2);
        }
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .welcome-section {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        .welcome-section h2 {
            color: #333;
            margin-bottom: 20px;
        }
        .welcome-section p {
            color: #666;
            font-size: 16px;
            line-height: 1.6;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 40px;
        }
        .feature-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s;
        }
        .feature-card:hover {
            transform: translateY(-5px);
        }
        .feature-card h3 {
            color: #667eea;
            margin-bottom: 15px;
        }
        .feature-card p {
            color: #666;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Hệ thống Bảo hành Thiết bị Điện tử</h1>
        <div class="user-info">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <span>Xin chào, ${sessionScope.fullName}</span>
                    <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="container">
        <div class="welcome-section">
            <h2>Chào mừng đến với Hệ thống Quản lý Bảo hành</h2>
            <p>Giải pháp toàn diện cho việc quản lý bảo hành và sửa chữa thiết bị điện tử</p>
        </div>

        <div class="features">
            <div class="feature-card">
                <h3>Quản lý Sản phẩm</h3>
                <p>Nhập và quản lý thông tin sản phẩm, khách hàng từ file Excel</p>
            </div>

            <div class="feature-card">
                <h3>Tiếp nhận Bảo hành</h3>
                <p>Tạo phiếu tiếp nhận, phân công kỹ thuật viên xử lý</p>
            </div>

            <div class="feature-card">
                <h3>Quản lý Kho</h3>
                <p>Theo dõi linh kiện, xuất nhập kho tự động</p>
            </div>

            <div class="feature-card">
                <h3>Theo dõi Tiến độ</h3>
                <p>Cập nhật và theo dõi tiến trình sửa chữa realtime</p>
            </div>

            <div class="feature-card">
                <h3>Portal Khách hàng</h3>
                <p>Khách hàng có thể tra cứu tình trạng đơn hàng</p>
            </div>

            <div class="feature-card">
                <h3>Báo cáo & Thống kê</h3>
                <p>Báo cáo chi tiết về hoạt động bảo hành</p>
            </div>
        </div>
    </div>
</body>
</html>
