<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Kỹ Thuật - Dashboard</title>
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
        .recent-tickets {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .recent-tickets h2 {
            margin-bottom: 20px;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #666;
        }
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        .status-in_progress {
            background: #cce5ff;
            color: #004085;
        }
        .status-completed {
            background: #d4edda;
            color: #155724;
        }
        .priority-high {
            color: #dc3545;
            font-weight: bold;
        }
        .priority-medium {
            color: #ffc107;
            font-weight: bold;
        }
        .priority-low {
            color: #28a745;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <h1>Quản Lý Kỹ Thuật - Dashboard</h1>
            <div class="user-info">
                <span>${sessionScope.fullName} (${sessionScope.role})</span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-logout">Đăng Xuất</a>
            </div>
        </div>
    </div>

    <div class="container">
        <c:if test="${not empty message}">
            <div style="background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                ${message}
            </div>
        </c:if>
        
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Yêu Cầu Chờ Tiếp Nhận</h3>
                <div class="number">${pendingCount != null ? pendingCount : 0}</div>
            </div>
            <div class="stat-card">
                <h3>Đang Chờ Phân Công</h3>
                <div class="number">${waitingAssignCount != null ? waitingAssignCount : 0}</div>
            </div>
            <div class="stat-card">
                <h3>Đang Sửa Chữa</h3>
                <div class="number">${inProgressCount != null ? inProgressCount : 0}</div>
            </div>
            <div class="stat-card">
                <h3>Hoàn Thành Tháng Này</h3>
                <div class="number">${completedThisMonth != null ? completedThisMonth : 0}</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="actions">
            <h2>Thao Tác Nhanh</h2>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/tech-manager/receive-product" class="btn btn-primary">
                    Tiếp Nhận Sản Phẩm BH
                </a>
                <a href="${pageContext.request.contextPath}/tech-manager/assign-ticket" class="btn btn-primary">
                    Phân Công Kỹ Thuật Viên
                </a>
                <a href="${pageContext.request.contextPath}/tech-manager/tickets" class="btn btn-secondary">
                    Xem Tất Cả Tickets
                </a>
                <a href="${pageContext.request.contextPath}/tech-manager/reports" class="btn btn-secondary">
                    Báo Cáo & Thống Kê
                </a>
            </div>
        </div>

        <!-- Recent Tickets -->
        <div class="recent-tickets">
            <h2>Tickets Gần Đây</h2>
            <c:if test="${empty recentTickets}">
                <p style="text-align: center; color: #999; padding: 40px;">Chưa có ticket nào</p>
            </c:if>
            <c:if test="${!empty recentTickets}">
                <table>
                    <thead>
                        <tr>
                            <th>Mã Ticket</th>
                            <th>Serial Number</th>
                            <th>Khách Hàng</th>
                            <th>Kỹ Thuật Viên</th>
                            <th>Trạng Thái</th>
                            <th>Ưu Tiên</th>
                            <th>Ngày Tiếp Nhận</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${recentTickets}" var="ticket">
                            <tr>
                                <td><strong>${ticket.ticketCode}</strong></td>
                                <td>${ticket.productSerialNumber}</td>
                                <td>${ticket.customerName}</td>
                                <td>${ticket.technicianName != null ? ticket.technicianName : '<em>Chưa phân công</em>'}</td>
                                <td>
                                    <span class="status-badge status-${ticket.status}">
                                        ${ticket.status}
                                    </span>
                                </td>
                                <td class="priority-${ticket.priority}">${ticket.priority}</td>
                                <td>${ticket.receivedDate}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/tech-manager/ticket-detail?id=${ticket.ticketId}">
                                        Chi Tiết
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>
    </div>
</body>
</html>
