<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Kho - Dashboard</title>
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
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header-content {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid #667eea;
        }
        .stat-card h3 {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .stat-card .number {
            font-size: 32px;
            font-weight: bold;
            color: #333;
        }
        .actions {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }
        .actions h2 {
            margin-bottom: 20px;
            color: #333;
        }
        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        .btn {
            padding: 15px 25px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.3s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary {
            background: #f0f0f0;
            color: #333;
        }
        .btn-secondary:hover {
            background: #e0e0e0;
        }
        .btn-logout {
            background: #ff4757;
            color: white;
            padding: 10px 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>Kho - Dashboard</h1>
            <div class="user-info">
                <span>${sessionScope.user.fullName} (${sessionScope.user.role})</span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-logout">Đăng Xuất</a>
            </div>
        </div>
    </div>

    <div class="container">
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Yêu Cầu Chờ Duyệt</h3>
                <div class="number">${pendingRequestsCount}</div>
            </div>
            <div class="stat-card">
                <h3>Đã Duyệt Hôm Nay</h3>
                <div class="number">${approvedTodayCount}</div>
            </div>
            <div class="stat-card">
                <h3>Từ Chối Hôm Nay</h3>
                <div class="number">${rejectedTodayCount}</div>
            </div>
            <div class="stat-card">
                <h3>Tổng Yêu Cầu Tháng Này</h3>
                <div class="number">${totalThisMonth}</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="actions">
            <h2>Thao Tác Nhanh</h2>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/warehouse/process-request" class="btn btn-primary">
                    Xử Lý Yêu Cầu Linh Kiện
                </a>
                <a href="${pageContext.request.contextPath}/warehouse/inventory" class="btn btn-secondary">
                    Quản Lý Kho
                </a>
                <a href="${pageContext.request.contextPath}/warehouse/reports" class="btn btn-secondary">
                    Báo Cáo & Thống Kê
                </a>
            </div>
        </div>
    </div>
</body>
</html>
