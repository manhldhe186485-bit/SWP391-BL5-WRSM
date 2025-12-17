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
        .form-section { background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container py-5">
        <div class="main-card">
            <div class="header-section">
                <h1><i class="fas fa-users me-3"></i>Quản Lý Khách Hàng</h1>
                <p class="mb-0">Thêm, sửa, xóa khách hàng trong hệ thống</p>
            </div>
            
            <div class="p-4">
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <div class="form-section">
                    <h4 class="mb-3">
                        <c:choose>
                            <c:when test="${not empty editMode}">
                                <i class="fas fa-edit me-2"></i>Cập Nhật Khách Hàng
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-plus-circle me-2"></i>Thêm Khách Hàng Mới
                            </c:otherwise>
                        </c:choose>
                    </h4>
                    
                    <form action="${pageContext.request.contextPath}/admin/customers" method="post">
                        <input type="hidden" name="action" value="${not empty editMode ? 'update' : 'create'}">
                        <c:if test="${not empty editMode}">
                            <input type="hidden" name="customerId" value="${customer.customerId}">
                        </c:if>
                        
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="fullName" class="form-label">Họ và Tên <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="fullName" name="fullName" value="${customer.fullName}" required>
                            </div>
                            
                            <div class="col-md-6">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email" value="${customer.email}">
                            </div>
                            
                            <div class="col-md-6">
                                <label for="phone" class="form-label">Số Điện Thoại <span class="text-danger">*</span></label>
                                <input type="tel" class="form-control" id="phone" name="phone" value="${customer.phone}" required>
                            </div>
                            
                            <div class="col-md-6">
                                <label for="address" class="form-label">Địa Chỉ</label>
                                <input type="text" class="form-control" id="address" name="address" value="${customer.address}">
                            </div>
                            
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary me-2">
                                    <i class="fas fa-save me-2"></i>${not empty editMode ? 'Cập Nhật' : 'Thêm Mới'}
                                </button>
                                <c:if test="${not empty editMode}">
                                    <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                                        <i class="fas fa-times me-2"></i>Hủy
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </form>
                </div>

                <div class="table-container">
                    <h4 class="mb-3"><i class="fas fa-list me-2"></i>Danh Sách Khách Hàng</h4>
                    <table class="table table-hover table-striped">
                        <thead class="table-dark sticky-top">
                            <tr>
                                <th>ID</th>
                                <th>Họ Tên</th>
                                <th>Email</th>
                                <th>Số Điện Thoại</th>
                                <th>Địa Chỉ</th>
                                <th>Ngày Tạo</th>
                                <th class="text-center">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty customers}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">
                                            <i class="fas fa-inbox fa-3x mb-3"></i>
                                            <p>Chưa có khách hàng nào trong hệ thống</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="cust" items="${customers}">
                                        <tr>
                                            <td>${cust.customerId}</td>
                                            <td><strong>${cust.fullName}</strong></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty cust.email}">
                                                        <i class="fas fa-envelope me-1"></i>${cust.email}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><i class="fas fa-phone me-1"></i>${cust.phone}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty cust.address}">${cust.address}</c:when>
                                                    <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <i class="far fa-calendar me-1"></i>
                                                <c:choose>
                                                    <c:when test="${not empty cust.createdAt}">${cust.createdAt}</c:when>
                                                    <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/admin/customers?action=edit&id=${cust.customerId}" class="btn btn-sm btn-warning me-1" title="Sửa">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/customers?action=delete&id=${cust.customerId}" class="btn btn-sm btn-danger" title="Xóa" onclick="return confirm('Bạn có chắc muốn xóa khách hàng ${cust.fullName}?')">
                                                    <i class="fas fa-trash"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="mt-4 text-center">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary">
                        <i class="fas fa-arrow-left me-2"></i>Quay Lại Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
