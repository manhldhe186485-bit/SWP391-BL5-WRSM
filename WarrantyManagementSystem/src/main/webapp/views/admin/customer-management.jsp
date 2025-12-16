<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Khách Hàng - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-card { background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .header-section { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; padding: 30px; border-radius: 15px 15px 0 0; }
        .table-container { max-height: 600px; overflow-y: auto; }
    </style>
</head>
<body>
    <div class="container py-5">
        <div class="main-card">
            <div class="header-section">
                <h1><i class="fas fa-users me-3"></i>Quản Lý Khách Hàng</h1>
                <p class="mb-0">Danh sách khách hàng đã import từ Excel</p>
            </div>
            
            <div class="p-4">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle me-2"></i>${error}
                    </div>
                </c:if>
                
                <c:if test="${not empty customers}">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5>Tổng cộng: <span class="badge bg-primary">${customers.size()}</span> khách hàng</h5>
                        <a href="${pageContext.request.contextPath}/admin/import-excel" class="btn btn-success">
                            <i class="fas fa-plus me-2"></i>Import thêm
                        </a>
                    </div>
                    
                    <div class="table-container">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Họ tên</th>
                                    <th>Email</th>
                                    <th>Số điện thoại</th>
                                    <th>Địa chỉ</th>
                                    <th>Ngày tạo</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="customer" items="${customers}">
                                    <tr>
                                        <td>${customer.customerId}</td>
                                        <td><strong>${customer.fullName}</strong></td>
                                        <td>
                                            <c:if test="${not empty customer.email}">
                                                <i class="fas fa-envelope text-primary me-1"></i>${customer.email}
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty customer.phone}">
                                                <i class="fas fa-phone text-success me-1"></i>${customer.phone}
                                            </c:if>
                                        </td>
                                        <td>${customer.address}</td>
                                        <td>
                                            <small class="text-muted">
                                                ${customer.createdAt}
                                            </small>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
                
                <c:if test="${empty customers}">
                    <div class="text-center py-5">
                        <i class="fas fa-users fa-4x text-muted mb-3"></i>
                        <h4 class="text-muted">Chưa có khách hàng nào</h4>
                        <p>Hãy import file Excel để thêm khách hàng</p>
                        <a href="${pageContext.request.contextPath}/admin/import-excel" class="btn btn-primary">
                            <i class="fas fa-upload me-2"></i>Import Excel
                        </a>
                    </div>
                </c:if>
                
                <div class="text-center mt-4">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left me-2"></i>Quay lại Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>