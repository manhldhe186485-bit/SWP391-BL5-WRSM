<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Hệ Thống Bảo Hành</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
        .stat-card.green { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .stat-card.orange { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
        .stat-card.red { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); }
        .upload-area {
            border: 3px dashed #667eea;
            border-radius: 10px;
            padding: 40px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        .upload-area:hover {
            background: #f8f9ff;
            border-color: #764ba2;
        }
        .table-hover tbody tr:hover {
            background-color: #f8f9ff;
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
                        <i class="fas fa-tools"></i> Admin Panel
                    </h4>
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    
                    <div class="mb-3">
                        <small class="text-white-50">Xin chào,</small>
                        <div class="fw-bold">${sessionScope.fullName}</div>
                    </div>
                    
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    
                    <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="active">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/import-excel">
                        <i class="fas fa-file-import"></i> Import Excel
                    </a>
                    
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    <small class="text-white-50 px-3">QUẢN LÝ DỮ LIỆU</small>
                    
                    <a href="${pageContext.request.contextPath}/admin/customers">
                        <i class="fas fa-users"></i> Danh sách khách hàng
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/products">
                        <i class="fas fa-box"></i> Danh sách sản phẩm
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/users">
                        <i class="fas fa-user-cog"></i> Danh sách nhân viên
                    </a>
                    
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    <small class="text-white-50 px-3">BÁO CÁO</small>
                    
                    <a href="${pageContext.request.contextPath}/views/admin/reports.jsp">
                        <i class="fas fa-chart-bar"></i> Thống kê & Báo cáo
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
                    <h2><i class="fas fa-tachometer-alt"></i> Dashboard</h2>
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
                                    <h3 class="mb-0">0</h3>
                                    <small>Tổng khách hàng</small>
                                </div>
                                <i class="fas fa-users fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card green">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h3 class="mb-0">0</h3>
                                    <small>Sản phẩm đã bán</small>
                                </div>
                                <i class="fas fa-box fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card orange">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h3 class="mb-0">0</h3>
                                    <small>Đơn bảo hành</small>
                                </div>
                                <i class="fas fa-ticket-alt fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card red">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h3 class="mb-0">0</h3>
                                    <small>Nhân viên</small>
                                </div>
                                <i class="fas fa-user-tie fa-3x opacity-50"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="row mt-4">
                    <div class="col-md-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0"><i class="fas fa-bolt"></i> Thao tác nhanh</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <a href="${pageContext.request.contextPath}/views/admin/import-excel.jsp" 
                                           class="btn btn-lg btn-outline-primary w-100 mb-3">
                                            <i class="fas fa-file-upload fa-2x d-block mb-2"></i>
                                            Import dữ liệu Excel
                                        </a>
                                    </div>
                                    <div class="col-md-4">
                                        <a href="${pageContext.request.contextPath}/views/admin/customers.jsp" 
                                           class="btn btn-lg btn-outline-success w-100 mb-3">
                                            <i class="fas fa-user-plus fa-2x d-block mb-2"></i>
                                            Thêm khách hàng mới
                                        </a>
                                    </div>
                                    <div class="col-md-4">
                                        <a href="${pageContext.request.contextPath}/views/admin/products.jsp" 
                                           class="btn btn-lg btn-outline-info w-100 mb-3">
                                            <i class="fas fa-box-open fa-2x d-block mb-2"></i>
                                            Thêm sản phẩm mới
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Activities -->
                <div class="row mt-4">
                    <div class="col-md-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-secondary text-white">
                                <h5 class="mb-0"><i class="fas fa-history"></i> Hoạt động gần đây</h5>
                            </div>
                            <div class="card-body">
                                <div class="text-center text-muted py-5">
                                    <i class="fas fa-inbox fa-3x mb-3"></i>
                                    <p>Chưa có hoạt động nào</p>
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
