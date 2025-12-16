<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Của Tôi - Kỹ Thuật Viên</title>
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
        .ticket-card {
            border-left: 4px solid #11998e;
            transition: all 0.3s;
            cursor: pointer;
        }
        .ticket-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transform: translateY(-2px);
        }
        .badge-new { background: #17a2b8; }
        .badge-in-progress { background: #ffc107; color: #000; }
        .badge-waiting-parts { background: #dc3545; }
        .badge-completed { background: #28a745; }
        .badge-delivered { background: #6c757d; }
        .filter-btn.active {
            background: #11998e !important;
            color: white !important;
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
                    
                    <a href="${pageContext.request.contextPath}/technician/dashboard">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/my-tickets.jsp" class="active">
                        <i class="fas fa-clipboard-list"></i> Đơn của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/create-warranty-slip.jsp">
                        <i class="fas fa-file-medical"></i> Tạo phiếu BH
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/request-parts.jsp">
                        <i class="fas fa-toolbox"></i> Yêu cầu linh kiện
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/update-progress.jsp">
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
                    <h2><i class="fas fa-clipboard-list"></i> Đơn bảo hành của tôi</h2>
                    <div>
                        <input type="text" class="form-control" placeholder="Tìm kiếm theo mã đơn, khách hàng..." id="searchInput">
                    </div>
                </div>

                <!-- Filter Tabs -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <div class="btn-group w-100" role="group">
                            <button type="button" class="btn btn-outline-secondary filter-btn active" data-status="all">
                                <i class="fas fa-list"></i> Tất cả <span class="badge bg-secondary ms-1">0</span>
                            </button>
                            <button type="button" class="btn btn-outline-info filter-btn" data-status="new">
                                <i class="fas fa-plus-circle"></i> Mới <span class="badge bg-info ms-1">0</span>
                            </button>
                            <button type="button" class="btn btn-outline-warning filter-btn" data-status="in-progress">
                                <i class="fas fa-spinner"></i> Đang sửa <span class="badge bg-warning text-dark ms-1">0</span>
                            </button>
                            <button type="button" class="btn btn-outline-danger filter-btn" data-status="waiting">
                                <i class="fas fa-pause"></i> Chờ linh kiện <span class="badge bg-danger ms-1">0</span>
                            </button>
                            <button type="button" class="btn btn-outline-success filter-btn" data-status="completed">
                                <i class="fas fa-check"></i> Hoàn thành <span class="badge bg-success ms-1">0</span>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Tickets List -->
                <div id="ticketsList">
                    <c:choose>
                        <c:when test="${empty tickets}">
                            <!-- Empty State -->
                            <div class="card shadow-sm">
                                <div class="card-body text-center py-5">
                                    <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                                    <h4 class="text-muted">Chưa có đơn nào được phân công</h4>
                                    <p class="text-muted">
                                        Tech Manager sẽ phân công đơn bảo hành cho bạn.<br>
                                        Các đơn sẽ hiển thị ở đây khi được giao.
                                    </p>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Tickets Cards -->
                            <c:forEach items="${tickets}" var="ticket">
                                <div class="card ticket-card mb-3">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-8">
                                                <div class="d-flex justify-content-between align-items-start mb-3">
                                                    <div>
                                                        <h5 class="mb-1">
                                                            <c:choose>
                                                                <c:when test="${ticket.status == 'ASSIGNED'}">
                                                                    <span class="badge badge-new me-2">Mới</span>
                                                                </c:when>
                                                                <c:when test="${ticket.status == 'IN_PROGRESS'}">
                                                                    <span class="badge badge-progress me-2">Đang sửa</span>
                                                                </c:when>
                                                                <c:when test="${ticket.status == 'WAITING_PARTS'}">
                                                                    <span class="badge badge-waiting me-2">Chờ linh kiện</span>
                                                                </c:when>
                                                                <c:when test="${ticket.status == 'COMPLETED'}">
                                                                    <span class="badge badge-completed me-2">Hoàn thành</span>
                                                                </c:when>
                                                            </c:choose>
                                                            ${ticket.ticketNumber}
                                                        </h5>
                                                        <p class="text-muted mb-1">
                                                            <i class="fas fa-user"></i> ${ticket.customer.fullName}
                                                            <span class="mx-2">|</span>
                                                            <i class="fas fa-phone"></i> ${ticket.customer.phone}
                                                        </p>
                                                    </div>
                                                    <small class="text-muted">
                                                        <i class="far fa-clock"></i> ${ticket.receivedDate}
                                                    </small>
                                                </div>
                                                
                                                <div class="mb-2">
                                                    <strong><i class="fas fa-box"></i> Sản phẩm:</strong> 
                                                    ${ticket.productSerial.serialNumber}
                                                </div>
                                                
                                                <div class="mb-2">
                                                    <strong><i class="fas fa-exclamation-circle"></i> Lỗi:</strong>
                                                    <span class="text-danger">${ticket.issueDescription}</span>
                                                </div>
                                                
                                                <div>
                                                    <small class="text-muted">
                                                        <span class="badge badge-${ticket.priority == 'URGENT' ? 'danger' : ticket.priority == 'HIGH' ? 'warning' : 'secondary'} me-2">
                                                            ${ticket.priority}
                                                        </span>
                                                        ${ticket.ticketType == 'WARRANTY' ? 'Bảo hành' : 'Sửa chữa có phí'}
                                                    </small>
                                                </div>
                                            </div>
                                            
                                            <div class="col-md-4 text-end">
                                                <c:choose>
                                                    <c:when test="${ticket.status == 'ASSIGNED'}">
                                                        <a href="${pageContext.request.contextPath}/technician/update-progress?ticketId=${ticket.ticketId}" 
                                                           class="btn btn-primary btn-sm mb-2 w-100">
                                                            <i class="fas fa-play"></i> Bắt đầu sửa
                                                        </a>
                                                    </c:when>
                                                    <c:when test="${ticket.status == 'IN_PROGRESS'}">
                                                        <a href="${pageContext.request.contextPath}/technician/update-progress?ticketId=${ticket.ticketId}" 
                                                           class="btn btn-warning btn-sm mb-2 w-100">
                                                            <i class="fas fa-tools"></i> Cập nhật tiến độ
                                                        </a>
                                                    </c:when>
                                                    <c:when test="${ticket.status == 'WAITING_PARTS'}">
                                                        <button class="btn btn-secondary btn-sm mb-2 w-100" disabled>
                                                            <i class="fas fa-hourglass-half"></i> Chờ linh kiện
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${ticket.status == 'COMPLETED'}">
                                                        <span class="badge badge-success">
                                                            <i class="fas fa-check-circle"></i> Đã hoàn thành
                                                        </span>
                                                    </c:when>
                                                </c:choose>
                                                <a href="${pageContext.request.contextPath}/technician/ticket-detail?id=${ticket.ticketId}" 
                                                   class="btn btn-outline-secondary btn-sm w-100">
                                                    <i class="fas fa-eye"></i> Xem chi tiết
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Pagination -->
                <nav aria-label="Page navigation" class="mt-4 d-none">
                    <ul class="pagination justify-content-center">
                        <li class="page-item disabled">
                            <a class="page-link" href="#" tabindex="-1">Trước</a>
                        </li>
                        <li class="page-item active"><a class="page-link" href="#">1</a></li>
                        <li class="page-item"><a class="page-link" href="#">2</a></li>
                        <li class="page-item"><a class="page-link" href="#">3</a></li>
                        <li class="page-item">
                            <a class="page-link" href="#">Sau</a>
                        </li>
                    </ul>
                </nav>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Filter buttons
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                
                const status = this.dataset.status;
                filterTickets(status);
            });
        });

        function filterTickets(status) {
            const tickets = document.querySelectorAll('.ticket-card');
            tickets.forEach(ticket => {
                if (status === 'all' || ticket.dataset.status === status) {
                    ticket.classList.remove('d-none');
                } else {
                    ticket.classList.add('d-none');
                }
            });
        }

        // Search
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const tickets = document.querySelectorAll('.ticket-card');
            
            tickets.forEach(ticket => {
                const text = ticket.textContent.toLowerCase();
                if (text.includes(searchTerm)) {
                    ticket.classList.remove('d-none');
                } else {
                    ticket.classList.add('d-none');
                }
            });
        });
    </script>
</body>
</html>
