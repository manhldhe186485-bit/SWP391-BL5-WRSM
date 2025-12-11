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
                    <a href="${pageContext.request.contextPath}/views/technician/create-invoice.jsp">
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

                    <!-- Sample Ticket Card (hidden by default, will be populated from backend) -->
                    <div class="card ticket-card mb-3 d-none" data-status="new">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <div>
                                            <h5 class="mb-1">
                                                <span class="badge badge-new me-2">Mới</span>
                                                #WR-2025-0001
                                            </h5>
                                            <p class="text-muted mb-1">
                                                <i class="fas fa-user"></i> Nguyễn Văn A
                                                <span class="mx-2">|</span>
                                                <i class="fas fa-phone"></i> 0123456789
                                            </p>
                                        </div>
                                        <small class="text-muted">
                                            <i class="far fa-clock"></i> 2 giờ trước
                                        </small>
                                    </div>
                                    
                                    <div class="mb-2">
                                        <strong><i class="fas fa-box"></i> Sản phẩm:</strong> 
                                        iPhone 14 Pro - S/N: ABC123456789
                                    </div>
                                    
                                    <div class="mb-2">
                                        <strong><i class="fas fa-exclamation-circle"></i> Lỗi:</strong>
                                        <span class="text-danger">Màn hình không hiển thị</span>
                                    </div>
                                    
                                    <div>
                                        <small class="text-muted">
                                            <i class="far fa-calendar"></i> Ngày tiếp nhận: 10/12/2025
                                        </small>
                                    </div>
                                </div>
                                
                                <div class="col-md-4 text-end">
                                    <div class="mb-2">
                                        <span class="badge bg-info">Còn BH: 8 tháng</span>
                                    </div>
                                    <div class="btn-group-vertical w-100">
                                        <button class="btn btn-sm btn-primary mb-1">
                                            <i class="fas fa-eye"></i> Xem chi tiết
                                        </button>
                                        <button class="btn btn-sm btn-success mb-1">
                                            <i class="fas fa-file-alt"></i> Tạo phiếu BH
                                        </button>
                                        <button class="btn btn-sm btn-info">
                                            <i class="fas fa-edit"></i> Cập nhật tiến độ
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
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
