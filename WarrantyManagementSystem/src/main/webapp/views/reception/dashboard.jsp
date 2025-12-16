<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lễ Tân - Dashboard</title>
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
        .card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        h2 {
            color: #333;
            margin-bottom: 20px;
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
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
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
            <h1>📋 Lễ Tân - Dashboard</h1>
            <div class="user-info">
                <span>👤 ${sessionScope.user.fullName} (${sessionScope.user.role})</span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-logout">Đăng Xuất</a>
            </div>
        </div>
    </div>

    <div class="container">
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>📦 Chờ Bàn Giao</h3>
                <div class="number">${readyToDeliverCount}</div>
            </div>
            <div class="stat-card">
                <h3>Đã Giao Hôm Nay</h3>
                <div class="number">${deliveredTodayCount}</div>
            </div>
            <div class="stat-card">
                <h3>💰 Chờ Thanh Toán</h3>
                <div class="number">${unpaidCount}</div>
            </div>
            <div class="stat-card">
                <h3>Tổng Giao Tháng Này</h3>
                <div class="number">${deliveredThisMonth}</div>
            </div>
        </div>

        <!-- Ready to Deliver -->
        <div class="card">
            <h2>📦 Sản Phẩm Sẵn Sàng Bàn Giao</h2>
            <c:if test="${empty readyTickets}">
                <p style="text-align: center; color: #999; padding: 40px;">
                    Không có sản phẩm nào sẵn sàng bàn giao
                </p>
            </c:if>
            <c:if test="${not empty readyTickets}">
                <table>
                    <thead>
                        <tr>
                            <th>Mã Ticket</th>
                            <th>Khách Hàng</th>
                            <th>SĐT</th>
                            <th>Sản Phẩm</th>
                            <th>Chi Phí</th>
                            <th>Thanh Toán</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${readyTickets}" var="ticket">
                            <tr>
                                <td><strong>${ticket.ticketCode}</strong></td>
                                <td>${ticket.customerName}</td>
                                <td>${ticket.customerPhone}</td>
                                <td>${ticket.productSerialNumber}</td>
                                <td>${ticket.totalCost} VNĐ</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ticket.paid}">
                                            <span style="color: #28a745;">Đã TT</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #dc3545;">❌ Chưa TT</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/reception/deliver-product?ticketId=${ticket.ticketId}" 
                                       class="btn btn-primary">
                                        📦 Bàn Giao
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
