<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tra Cứu Bảo Hành</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }
        .header h1 {
            font-size: 36px;
            margin-bottom: 10px;
        }
        .search-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 600;
        }
        input {
            width: 100%;
            padding: 15px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border 0.3s;
        }
        input:focus {
            border-color: #667eea;
            outline: none;
        }
        .btn {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
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
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .ticket-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 20px;
        }
        .ticket-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #eee;
        }
        .ticket-code {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
        }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-assigned { background: #d1ecf1; color: #0c5460; }
        .status-diagnosing { background: #cce5ff; color: #004085; }
        .status-waiting_parts { background: #e2e3e5; color: #383d41; }
        .status-in_progress { background: #bee5eb; color: #0c5460; }
        .status-completed { background: #d4edda; color: #155724; }
        .status-delivered { background: #d4edda; color: #155724; }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 20px;
        }
        .info-item {
            padding: 12px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        .info-item strong {
            display: block;
            color: #666;
            margin-bottom: 5px;
            font-size: 12px;
        }
        .info-item span {
            color: #333;
            font-size: 16px;
        }
        .timeline {
            margin-top: 30px;
        }
        .timeline h3 {
            color: #333;
            margin-bottom: 20px;
        }
        .timeline-item {
            position: relative;
            padding-left: 30px;
            padding-bottom: 20px;
            border-left: 2px solid #e0e0e0;
        }
        .timeline-item:last-child {
            border-left: none;
        }
        .timeline-dot {
            position: absolute;
            left: -6px;
            top: 0;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #667eea;
        }
        .timeline-content {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 8px;
        }
        .timeline-date {
            font-size: 12px;
            color: #999;
            margin-bottom: 5px;
        }
        .timeline-text {
            color: #333;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔍 Tra Cứu Tiến Độ Bảo Hành</h1>
            <p>Nhập mã ticket hoặc số serial để tra cứu</p>
        </div>

        <!-- Search Form -->
        <div class="search-card">
            <form action="${pageContext.request.contextPath}/customer/track-ticket" method="get">
                <div class="form-group">
                    <label for="ticketCode">Mã Ticket</label>
                    <input type="text" id="ticketCode" name="ticketCode" 
                           value="${ticketCode}"
                           placeholder="Ví dụ: WTY-2024-00001">
                </div>
                
                <div style="text-align: center; margin: 20px 0;">
                    <strong>HOẶC</strong>
                </div>

                <div class="form-group">
                    <label for="serialNumber">Số Serial Sản Phẩm</label>
                    <input type="text" id="serialNumber" name="serialNumber" 
                           value="${serialNumber}"
                           placeholder="Nhập số serial trên sản phẩm">
                </div>

                <button type="submit" class="btn btn-primary">🔍 Tra Cứu</button>
            </form>
        </div>

        <!-- Error Message -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <!-- Ticket Info -->
        <c:if test="${not empty ticket}">
            <div class="ticket-card">
                <div class="ticket-header">
                    <div class="ticket-code">${ticket.ticketCode}</div>
                    <div class="status-badge status-${ticket.status}">
                        ${ticket.status}
                    </div>
                </div>

                <div class="info-grid">
                    <div class="info-item">
                        <strong>📱 Serial Number</strong>
                        <span>${ticket.productSerialNumber}</span>
                    </div>
                    <div class="info-item">
                        <strong>👤 Khách Hàng</strong>
                        <span>${ticket.customerName}</span>
                    </div>
                    <div class="info-item">
                        <strong>📞 Số Điện Thoại</strong>
                        <span>${ticket.customerPhone}</span>
                    </div>
                    <div class="info-item">
                        <strong>📅 Ngày Tiếp Nhận</strong>
                        <span>${ticket.receivedDate}</span>
                    </div>
                    <div class="info-item">
                        <strong>⚠️ Vấn Đề</strong>
                        <span>${ticket.issueDescription}</span>
                    </div>
                    <div class="info-item">
                        <strong>⏰ Dự Kiến Hoàn Thành</strong>
                        <span>${ticket.estimatedCompletionDate != null ? ticket.estimatedCompletionDate : 'Chưa xác định'}</span>
                    </div>
                </div>

                <c:if test="${ticket.totalCost != null && ticket.totalCost > 0}">
                    <div class="info-grid">
                        <div class="info-item">
                            <strong>💰 Tổng Chi Phí</strong>
                            <span style="font-size: 20px; font-weight: bold; color: #dc3545;">
                                ${ticket.totalCost} VNĐ
                            </span>
                        </div>
                        <div class="info-item">
                            <strong>💳 Trạng Thái Thanh Toán</strong>
                            <c:choose>
                                <c:when test="${ticket.paid}">
                                    <span style="font-weight: bold; color: #28a745;">
                                        Đã Thanh Toán
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span style="font-weight: bold; color: #dc3545;">
                                        ❌ Chưa Thanh Toán
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>

                <!-- Timeline -->
                <div class="timeline">
                    <h3>Lịch Sử Tiến Độ</h3>
                    
                    <c:if test="${not empty progressLogs}">
                        <c:forEach items="${progressLogs}" var="log">
                            <div class="timeline-item">
                                <div class="timeline-dot"></div>
                                <div class="timeline-content">
                                    <div class="timeline-date">${log.logDate}</div>
                                    <div class="timeline-text">
                                        <strong>${log.statusChange}</strong><br>
                                        ${log.description}
                                        <c:if test="${not empty log.updatedBy}">
                                            <br><small>Bởi: ${log.updatedBy}</small>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:if>
                    
                    <c:if test="${empty progressLogs}">
                        <p style="color: #999; padding: 20px; text-align: center;">
                            Chưa có cập nhật tiến độ
                        </p>
                    </c:if>
                </div>
            </div>
        </c:if>
    </div>
</body>
</html>
