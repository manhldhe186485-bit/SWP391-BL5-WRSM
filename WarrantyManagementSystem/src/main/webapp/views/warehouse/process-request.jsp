<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Xử Lý Yêu Cầu Linh Kiện</title>
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
            margin-right: 5px;
        }
        .btn-success {
            background: #28a745;
            color: white;
        }
        .btn-danger {
            background: #dc3545;
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
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
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
        .status-approved {
            background: #d4edda;
            color: #155724;
        }
        .status-rejected {
            background: #f8d7da;
            color: #721c24;
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
        .request-details {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-top: 10px;
        }
        .request-items {
            margin-top: 10px;
        }
        .request-items ul {
            list-style: none;
            padding-left: 0;
        }
        .request-items li {
            padding: 5px 0;
            border-bottom: 1px solid #dee2e6;
        }
        .form-group {
            margin: 15px 0;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: 600;
        }
        textarea, input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        textarea {
            min-height: 80px;
        }
        .stock-warning {
            color: #dc3545;
            font-weight: bold;
        }
        .stock-ok {
            color: #28a745;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📦 Xử Lý Yêu Cầu Linh Kiện</h1>
    </div>

    <div class="container">
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <!-- Pending Requests -->
        <div class="card">
            <h2>⏳ Yêu Cầu Chờ Xử Lý (${pendingRequests.size()})</h2>
            
            <c:if test="${empty pendingRequests}">
                <p style="text-align: center; color: #999; padding: 40px;">
                    Không có yêu cầu nào chờ xử lý
                </p>
            </c:if>

            <c:if test="${not empty pendingRequests}">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Ticket</th>
                            <th>Kỹ Thuật Viên</th>
                            <th>Ưu Tiên</th>
                            <th>Ngày Yêu Cầu</th>
                            <th>Linh Kiện</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pendingRequests}" var="request">
                            <tr>
                                <td><strong>#${request.requestId}</strong></td>
                                <td>${request.ticketCode}</td>
                                <td>${request.technicianName}</td>
                                <td class="priority-${request.priority}">${request.priority}</td>
                                <td>${request.requestDate}</td>
                                <td>
                                    <button type="button" class="btn btn-secondary" 
                                            onclick="toggleDetails(<c:out value='${request.requestId}'/>)">
                                        📋 Xem Chi Tiết
                                    </button>
                                    <div id="details_${request.requestId}" class="request-details" style="display: none;">
                                        <strong>Ghi chú:</strong> ${request.notes != null ? request.notes : 'Không có'}
                                        <div class="request-items">
                                            <strong>Danh sách linh kiện:</strong>
                                            <ul>
                                                <c:forEach items="${request.items}" var="item">
                                                    <li>
                                                        <strong>${item.partName}</strong> (${item.partNumber})
                                                        - SL yêu cầu: <strong>${item.quantityRequested}</strong>
                                                        - Tồn kho: 
                                                        <span class="${item.quantityAvailable >= item.quantityRequested ? 'stock-ok' : 'stock-warning'}">
                                                            ${item.quantityAvailable}
                                                        </span>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="status-badge status-${request.status}">
                                        ${request.status}
                                    </span>
                                </td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/warehouse/process-request" 
                                          method="post" style="display: inline;">
                                        <input type="hidden" name="requestId" value="${request.requestId}">
                                        <input type="hidden" name="action" value="approve">
                                        <button type="submit" class="btn btn-success" 
                                                onclick="return confirm('Xác nhận DUYỆT yêu cầu này?')">
                                            Duyệt
                                        </button>
                                    </form>
                                    <button type="button" class="btn btn-danger" 
                                            onclick="showRejectForm(<c:out value='${request.requestId}'/>)">
                                        ❌ Từ Chối
                                    </button>
                                    
                                    <!-- Reject Form (hidden) -->
                                    <div id="reject_form_${request.requestId}" style="display: none; margin-top: 10px;">
                                        <form action="${pageContext.request.contextPath}/warehouse/process-request" 
                                              method="post">
                                            <input type="hidden" name="requestId" value="${request.requestId}">
                                            <input type="hidden" name="action" value="reject">
                                            <div class="form-group">
                                                <label>Lý do từ chối:</label>
                                                <textarea name="notes" required 
                                                          placeholder="Nhập lý do từ chối yêu cầu..."></textarea>
                                            </div>
                                            <button type="submit" class="btn btn-danger">Xác Nhận Từ Chối</button>
                                            <button type="button" class="btn btn-secondary" 
                                                    onclick="hideRejectForm(<c:out value='${request.requestId}'/>)">Hủy</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>

        <div style="margin-top: 20px;">
            <a href="${pageContext.request.contextPath}/warehouse/dashboard" class="btn btn-secondary">
                ⬅️ Quay Lại Dashboard
            </a>
        </div>
    </div>

    <script>
        function toggleDetails(requestId) {
            const details = document.getElementById('details_' + requestId);
            details.style.display = details.style.display === 'none' ? 'block' : 'none';
        }

        function showRejectForm(requestId) {
            document.getElementById('reject_form_' + requestId).style.display = 'block';
        }

        function hideRejectForm(requestId) {
            document.getElementById('reject_form_' + requestId).style.display = 'none';
        }
    </script>
</body>
</html>
