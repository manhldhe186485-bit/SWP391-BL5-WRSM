<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Phân Công Kỹ Thuật Viên</title>
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
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
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
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .btn:hover {
            opacity: 0.9;
        }
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
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
        .technician-select {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
            min-width: 200px;
        }
        .workload-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            background: #e9ecef;
            color: #495057;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        .empty-state img {
            width: 100px;
            opacity: 0.3;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Phân Công Kỹ Thuật Viên</h1>
    </div>

    <div class="container">
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <!-- Pending Tickets -->
        <div class="card">
            <h2>Tickets Chờ Phân Công <c:if test="${not empty pendingTickets}">(${pendingTickets.size()})</c:if></h2>
            
            <c:if test="${empty pendingTickets}">
                <div class="empty-state">
                    <h3>Tất Cả Tickets Đã Được Phân Công</h3>
                    <p>Không có ticket nào đang chờ phân công</p>
                </div>
            </c:if>

            <c:if test="${not empty pendingTickets}">
                <form action="${pageContext.request.contextPath}/tech-manager/assign-ticket" method="post">
                    <table>
                        <thead>
                            <tr>
                                <th>Mã Ticket</th>
                                <th>Serial Number</th>
                                <th>Khách Hàng</th>
                                <th>Vấn Đề</th>
                                <th>Ưu Tiên</th>
                                <th>Ngày Tiếp Nhận</th>
                                <th>Phân Công Cho</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${pendingTickets}" var="ticket">
                                <tr>
                                    <td><strong>${ticket.ticketNumber}</strong></td>
                                    <td>${ticket.productSerial.serialNumber}</td>
                                    <td>${ticket.customer.fullName}</td>
                                    <td style="max-width: 200px;">
                                        ${ticket.issueDescription.length() > 50 ? 
                                          ticket.issueDescription.substring(0, 50) + '...' : 
                                          ticket.issueDescription}
                                    </td>
                                    <td class="priority-${ticket.priority}">${ticket.priority}</td>
                                    <td>${ticket.receivedDate}</td>
                                    <td>
                                        <select name="technician_${ticket.ticketId}" class="technician-select" required>
                                            <option value="">-- Chọn KTV --</option>
                                            <c:forEach items="${technicians}" var="tech">
                                                <option value="${tech.userId}">
                                                    ${tech.fullName} 
                                                    <c:if test="${not empty technicianWorkload[tech.userId]}">
                                                        (${technicianWorkload[tech.userId]} tickets)
                                                    </c:if>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                    <td>
                                        <button type="submit" name="ticketId" value="${ticket.ticketId}" 
                                                class="btn btn-primary">
                                            Phân Công
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </form>
            </c:if>
        </div>

        <!-- Technicians Workload -->
        <div class="card">
            <h2>Tình Trạng Kỹ Thuật Viên</h2>
            <table>
                <thead>
                    <tr>
                        <th>Họ Tên</th>
                        <th>Email</th>
                        <th>SĐT</th>
                        <th>Tickets Đang Xử Lý</th>
                        <th>Trạng Thái</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${technicians}" var="tech">
                        <tr>
                            <td><strong>${tech.fullName}</strong></td>
                            <td>${tech.email}</td>
                            <td>${tech.phone}</td>
                            <td>
                                <span class="workload-badge">
                                    ${technicianWorkload[tech.userId] != null ? technicianWorkload[tech.userId] : 0} tickets
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${technicianWorkload[tech.userId] == 0}">
                                        <span style="color: #28a745;">Rảnh</span>
                                    </c:when>
                                    <c:when test="${technicianWorkload[tech.userId] < 5}">
                                        <span style="color: #ffc107;">Bình Thường</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #dc3545;">Bận</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div style="margin-top: 20px;">
            <a href="${pageContext.request.contextPath}/tech-manager/dashboard" class="btn btn-secondary">
                ⬅️ Quay Lại Dashboard
            </a>
        </div>
    </div>
</body>
</html>
