<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xem Tất Cả Tickets - Tech Manager</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 500;
        }
        .status-PENDING_ASSIGNMENT { background-color: #ffc107; color: #000; }
        .status-ASSIGNED { background-color: #17a2b8; color: #fff; }
        .status-IN_DIAGNOSIS { background-color: #6c757d; color: #fff; }
        .status-AWAITING_PARTS { background-color: #fd7e14; color: #fff; }
        .status-IN_REPAIR { background-color: #007bff; color: #fff; }
        .status-QUALITY_CHECK { background-color: #6610f2; color: #fff; }
        .status-COMPLETED { background-color: #28a745; color: #fff; }
        .status-DELIVERED { background-color: #20c997; color: #fff; }
        .status-CANCELLED { background-color: #dc3545; color: #fff; }
        
        .priority-LOW { color: #28a745; }
        .priority-MEDIUM { color: #ffc107; }
        .priority-HIGH { color: #fd7e14; }
        .priority-CRITICAL { color: #dc3545; }
        
        .table-hover tbody tr:hover {
            background-color: #f8f9fa;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/tech-manager/dashboard">
                Quản Lý Kỹ Thuật
            </a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <span class="navbar-text me-3">${sessionScope.fullName}</span>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/logout">Đăng Xuất</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2">
                <div class="list-group">
                    <a href="${pageContext.request.contextPath}/tech-manager/dashboard" 
                       class="list-group-item list-group-item-action">
                        Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/receive-product" 
                       class="list-group-item list-group-item-action">
                        Tiếp Nhận SP
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/assign-ticket" 
                       class="list-group-item list-group-item-action">
                        Phân Công
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/tickets" 
                       class="list-group-item list-group-item-action active">
                        Xem Tickets
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/reports" 
                       class="list-group-item list-group-item-action">
                        Báo Cáo
                    </a>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-10">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">Tất Cả Tickets Bảo Hành</h4>
                    </div>
                    <div class="card-body">
                        <!-- Filter -->
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <form method="GET" action="${pageContext.request.contextPath}/tech-manager/tickets">
                                    <div class="input-group">
                                        <select name="status" class="form-select">
                                            <option value="ALL" ${selectedStatus == 'ALL' || empty selectedStatus ? 'selected' : ''}>
                                                Tất Cả Trạng Thái
                                            </option>
                                            <option value="PENDING_ASSIGNMENT" ${selectedStatus == 'PENDING_ASSIGNMENT' ? 'selected' : ''}>
                                                Chờ Phân Công
                                            </option>
                                            <option value="ASSIGNED" ${selectedStatus == 'ASSIGNED' ? 'selected' : ''}>
                                                Đã Phân Công
                                            </option>
                                            <option value="IN_DIAGNOSIS" ${selectedStatus == 'IN_DIAGNOSIS' ? 'selected' : ''}>
                                                Đang Chẩn Đoán
                                            </option>
                                            <option value="AWAITING_PARTS" ${selectedStatus == 'AWAITING_PARTS' ? 'selected' : ''}>
                                                Chờ Linh Kiện
                                            </option>
                                            <option value="IN_REPAIR" ${selectedStatus == 'IN_REPAIR' ? 'selected' : ''}>
                                                Đang Sửa
                                            </option>
                                            <option value="QUALITY_CHECK" ${selectedStatus == 'QUALITY_CHECK' ? 'selected' : ''}>
                                                Kiểm Tra Chất Lượng
                                            </option>
                                            <option value="COMPLETED" ${selectedStatus == 'COMPLETED' ? 'selected' : ''}>
                                                Hoàn Thành
                                            </option>
                                            <option value="DELIVERED" ${selectedStatus == 'DELIVERED' ? 'selected' : ''}>
                                                Đã Giao
                                            </option>
                                            <option value="CANCELLED" ${selectedStatus == 'CANCELLED' ? 'selected' : ''}>
                                                Đã Hủy
                                            </option>
                                        </select>
                                        <button type="submit" class="btn btn-primary">Lọc</button>
                                    </div>
                                </form>
                            </div>
                            <div class="col-md-8 text-end">
                                <span class="badge bg-info fs-6">Tổng: ${tickets.size()} tickets</span>
                            </div>
                        </div>

                        <!-- Tickets Table -->
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Mã Ticket</th>
                                        <th>Serial</th>
                                        <th>Khách Hàng</th>
                                        <th>Mô Tả</th>
                                        <th>Độ Ưu Tiên</th>
                                        <th>Loại</th>
                                        <th>Trạng Thái</th>
                                        <th>Ngày Nhận</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty tickets}">
                                            <tr>
                                                <td colspan="8" class="text-center text-muted py-5">
                                                    <i class="fas fa-inbox fa-3x mb-3"></i>
                                                    <p>Không có tickets nào</p>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="ticket" items="${tickets}">
                                                <tr onclick="window.location.href='${pageContext.request.contextPath}/tech-manager/ticket-detail?id=${ticket.ticketId}'">
                                                    <td><strong>${ticket.ticketNumber}</strong></td>
                                                    <td>${ticket.serialId}</td>
                                                    <td>${ticket.customerId}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.issueDescription.length() > 50}">
                                                                ${ticket.issueDescription.substring(0, 50)}...
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${ticket.issueDescription}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <span class="priority-${ticket.priority}">
                                                            <i class="fas fa-circle"></i> ${ticket.priority}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ticket.ticketType == 'WARRANTY'}">
                                                                <span class="badge bg-success">Bảo Hành</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning text-dark">Trả Phí</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <span class="status-badge status-${ticket.status}">
                                                            ${ticket.status}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${ticket.receivedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
