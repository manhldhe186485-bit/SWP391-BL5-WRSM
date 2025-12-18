<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kỹ Thuật Viên - Hệ Thống Bảo Hành</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
        }
        .sidebar a {
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            padding: 12px 20px;
            display: block;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        .stat-card {
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            color: white;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .stat-card.blue { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .stat-card.green { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); }
        .stat-card.orange { background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%); }
        .stat-card.yellow { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .ticket-card {
            border-left: 4px solid #11998e;
            margin-bottom: 15px;
            transition: all 0.3s;
        }
        .ticket-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transform: translateY(-2px);
        }
        .badge-status {
            font-size: 0.85rem;
            padding: 5px 12px;
        }
        .timeline {
            position: relative;
            padding-left: 30px;
        }
        .timeline::before {
            content: '';
            position: absolute;
            left: 8px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #dee2e6;
        }
        .timeline-item {
            position: relative;
            margin-bottom: 20px;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -26px;
            top: 0;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            background: #11998e;
            border: 3px solid #fff;
            box-shadow: 0 0 0 2px #dee2e6;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-2 d-md-block sidebar">
                <div class="p-3">
                    <h4 class="text-center mb-4">
                        <i class="fas fa-wrench"></i> Kỹ Thuật
                    </h4>
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    
                    <div class="mb-3">
                        <small class="text-white-50">Xin chào,</small>
                        <div class="fw-bold">${sessionScope.fullName}</div>
                    </div>
                    
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    
                    <a href="${pageContext.request.contextPath}/technician/dashboard" class="active">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/receive-product">
                        <i class="fas fa-inbox"></i> Tiếp nhận sản phẩm
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/my-tickets">
                        <i class="fas fa-clipboard-list"></i> Đơn của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/request-parts">
                        <i class="fas fa-toolbox"></i> Yêu cầu linh kiện
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/update-progress">
                        <i class="fas fa-tasks"></i> Cập nhật tiến độ
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/create-invoice">
                        <i class="fas fa-receipt"></i> Tạo phiếu thanh toán
                    </a>
                    
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    
                    <a href="${pageContext.request.contextPath}/logout">
                        <i class="fas fa-sign-out-alt"></i> Đăng xuất
                    </a>
                </div>
            </nav>

            <!-- Main Content -->
            <main class="col-md-10 ms-sm-auto px-4 py-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-tachometer-alt"></i> Dashboard - Kỹ Thuật Viên</h2>
                    <div>
                        <span class="text-muted">
                            <i class="far fa-calendar"></i> 
                            <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %>
                        </span>
                    </div>
                </div>

                <!-- Statistics Cards -->
                <div class="row">
                    <div class="col-md-3">
                        <div class="stat-card blue">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h3 class="mb-0">${newAssignedCount != null ? newAssignedCount : 0}</h3>
                                    <small>Đơn được giao</small>
                                </div>
                                <i class="fas fa-clipboard-list fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card green">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h3 class="mb-0">${inProgressCount != null ? inProgressCount : 0}</h3>
                                    <small>Đang sửa chữa</small>
                                </div>
                                <i class="fas fa-tools fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card orange">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h3 class="mb-0">${waitingPartsCount != null ? waitingPartsCount : 0}</h3>
                                    <small>Chờ linh kiện</small>
                                </div>
                                <i class="fas fa-pause-circle fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card yellow">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h3 class="mb-0">${completedCount != null ? completedCount : 0}</h3>
                                    <small>Hoàn thành</small>
                                </div>
                                <i class="fas fa-check-circle fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="row mt-4">
                    <div class="col-md-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="fas fa-bolt"></i> Thao tác nhanh</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-3">
                                        <a href="${pageContext.request.contextPath}/technician/receive-product" 
                                           class="btn btn-lg btn-outline-danger w-100 mb-3">
                                            <i class="fas fa-inbox fa-2x d-block mb-2"></i>
                                            Tiếp nhận sản phẩm BH
                                        </a>
                                    </div>
                                    <div class="col-md-3">
                                        <a href="${pageContext.request.contextPath}/technician/my-tickets" 
                                           class="btn btn-lg btn-outline-primary w-100 mb-3">
                                            <i class="fas fa-list fa-2x d-block mb-2"></i>
                                            Xem đơn của tôi
                                        </a>
                                    </div>
                                    <div class="col-md-3">
                                        <a href="${pageContext.request.contextPath}/technician/request-parts" 
                                           class="btn btn-lg btn-outline-warning w-100 mb-3">
                                            <i class="fas fa-toolbox fa-2x d-block mb-2"></i>
                                            Yêu cầu linh kiện
                                        </a>
                                    </div>
                                    <div class="col-md-3">
                                        <a href="${pageContext.request.contextPath}/technician/create-invoice" 
                                           class="btn btn-lg btn-outline-info w-100 mb-3">
                                            <i class="fas fa-receipt fa-2x d-block mb-2"></i>
                                            Tạo phiếu TT
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- My Tickets -->
                <div class="row mt-4">
                    <div class="col-md-8">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-clipboard-list"></i> Đơn được giao cho tôi</h5>
                                <span class="badge bg-light text-dark">${totalTickets != null ? totalTickets : 0} đơn</span>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty myTickets}">
                                        <div class="text-center text-muted py-5">
                                            <i class="fas fa-inbox fa-3x mb-3"></i>
                                            <p>Chưa có đơn nào được giao</p>
                                            <small class="text-muted">
                                                Các đơn bảo hành được phân công bởi Tech Manager sẽ hiển thị ở đây
                                            </small>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead>
                                                    <tr>
                                                        <th>Mã đơn</th>
                                                        <th>Khách hàng</th>
                                                        <th>Sản phẩm</th>
                                                        <th>Trạng thái</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${myTickets}" var="ticket" varStatus="status">
                                                        <c:if test="${status.index < 5}">
                                                            <tr>
                                                                <td><strong>${ticket.ticketNumber}</strong></td>
                                                                <td>${ticket.customer.fullName}</td>
                                                                <td>${ticket.productSerial.serialNumber}</td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${ticket.status == 'ASSIGNED'}">
                                                                            <span class="badge bg-primary">Mới</span>
                                                                        </c:when>
                                                                        <c:when test="${ticket.status == 'IN_PROGRESS'}">
                                                                            <span class="badge bg-warning">Đang sửa</span>
                                                                        </c:when>
                                                                        <c:when test="${ticket.status == 'WAITING_PARTS'}">
                                                                            <span class="badge bg-secondary">Chờ linh kiện</span>
                                                                        </c:when>
                                                                        <c:when test="${ticket.status == 'COMPLETED'}">
                                                                            <span class="badge bg-success">Hoàn thành</span>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/technician/update-progress?ticketId=${ticket.ticketId}" 
                                                                       class="btn btn-sm btn-primary">
                                                                        <i class="fas fa-edit"></i> Xử lý
                                                                    </a>
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                            <div class="text-center mt-3">
                                                <a href="${pageContext.request.contextPath}/technician/my-tickets" class="btn btn-outline-primary">
                                                    Xem tất cả ${totalTickets} đơn <i class="fas fa-arrow-right"></i>
                                                </a>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Pending Actions -->
                    <div class="col-md-4">
                        <div class="card shadow-sm">
                            <div class="card-header bg-warning">
                                <h5 class="mb-0"><i class="fas fa-exclamation-triangle"></i> Cần xử lý</h5>
                            </div>
                            <div class="card-body">
                                <div class="text-center text-muted py-4">
                                    <i class="fas fa-check-circle fa-3x mb-3"></i>
                                    <p class="mb-0">Tất cả đã xử lý</p>
                                </div>
                            </div>
                        </div>

                        <!-- Today's Tasks -->
                        <div class="card shadow-sm mt-3">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0"><i class="fas fa-calendar-day"></i> Nhiệm vụ hôm nay</h5>
                            </div>
                            <div class="card-body">
                                <div class="text-center text-muted py-3">
                                    <i class="fas fa-tasks fa-2x mb-3"></i>
                                    <p class="mb-0 small">Chưa có nhiệm vụ</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
