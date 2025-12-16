<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Phiếu Bảo Hành</title>
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
            border-radius: 8px;
            margin: 5px 0;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        .warranty-card {
            border: 2px solid #28a745;
            border-radius: 10px;
            padding: 20px;
            background: #f8fff9;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 sidebar p-4">
                <div class="text-center mb-4">
                    <i class="fas fa-tools fa-3x"></i>
                    <h5 class="mt-2">Kỹ Thuật Viên</h5>
                    <small>${sessionScope.username}</small>
                </div>
                <nav>
                    <a href="${pageContext.request.contextPath}/technician/dashboard">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/my-tickets">
                        <i class="fas fa-clipboard-list"></i> Đơn của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/update-progress">
                        <i class="fas fa-edit"></i> Cập nhật tiến độ
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/request-parts">
                        <i class="fas fa-toolbox"></i> Yêu cầu linh kiện
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/create-warranty-slip" class="active">
                        <i class="fas fa-certificate"></i> Tạo phiếu BH
                    </a>
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    <a href="${pageContext.request.contextPath}/logout">
                        <i class="fas fa-sign-out-alt"></i> Đăng xuất
                    </a>
                </nav>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-certificate"></i> Tạo Phiếu Bảo Hành</h2>
                    <span class="text-muted">
                        <i class="far fa-calendar"></i>
                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %>
                    </span>
                </div>

                <!-- Success/Error Messages -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${not empty ticket}">
                        <!-- Warranty Slip Form -->
                        <div class="row">
                            <div class="col-md-8">
                                <div class="warranty-card">
                                    <h4 class="text-success mb-3">
                                        <i class="fas fa-award"></i> Phiếu Bảo Hành Sau Sửa Chữa
                                    </h4>

                                    <form method="post" action="${pageContext.request.contextPath}/technician/create-warranty-slip">
                                        <input type="hidden" name="ticketId" value="${ticket.ticketId}">
                                        <input type="hidden" name="serialId" value="${ticket.serialId}">

                                        <!-- Ticket Info -->
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label"><strong>Mã Ticket:</strong></label>
                                                <p class="form-control-plaintext">${ticket.ticketNumber}</p>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label"><strong>Khách hàng:</strong></label>
                                                <p class="form-control-plaintext">${ticket.customer.fullName}</p>
                                            </div>
                                        </div>

                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label"><strong>Sản phẩm:</strong></label>
                                                <p class="form-control-plaintext">${productSerial.productName}</p>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label"><strong>Serial Number:</strong></label>
                                                <p class="form-control-plaintext">${productSerial.serialNumber}</p>
                                            </div>
                                        </div>

                                        <hr>

                                        <!-- Warranty Period -->
                                        <div class="mb-3">
                                            <label class="form-label">
                                                <i class="fas fa-calendar-alt"></i> Thời hạn bảo hành (tháng) *
                                            </label>
                                            <select name="warrantyMonths" class="form-select" required>
                                                <option value="3">3 tháng</option>
                                                <option value="6" selected>6 tháng</option>
                                                <option value="12">12 tháng</option>
                                                <option value="24">24 tháng</option>
                                            </select>
                                            <small class="text-muted">Bảo hành bắt đầu từ hôm nay</small>
                                        </div>

                                        <!-- Repair Summary -->
                                        <div class="mb-3">
                                            <label class="form-label">
                                                <i class="fas fa-wrench"></i> Tóm tắt sửa chữa *
                                            </label>
                                            <textarea name="repairSummary" class="form-control" rows="3" required 
                                                      placeholder="Mô tả công việc đã thực hiện...">Đã kiểm tra và sửa chữa: ${ticket.issueDescription}</textarea>
                                        </div>

                                        <!-- Replaced Parts -->
                                        <div class="mb-3">
                                            <label class="form-label">
                                                <i class="fas fa-cogs"></i> Linh kiện đã thay thế
                                            </label>
                                            <textarea name="replacedParts" class="form-control" rows="2" 
                                                      placeholder="Danh sách linh kiện đã thay (nếu có)"></textarea>
                                        </div>

                                        <!-- Warranty Terms -->
                                        <div class="mb-3">
                                            <label class="form-label">
                                                <i class="fas fa-file-contract"></i> Điều khoản bảo hành
                                            </label>
                                            <textarea name="warrantyTerms" class="form-control" rows="3">- Bảo hành lỗi phát sinh do quá trình sửa chữa
- Không bảo hành các lỗi do người dùng gây ra
- Không bảo hành các bộ phận đã được thay thế bên ngoài
- Bảo hành không áp dụng nếu thiết bị bị rơi, vào nước sau khi sửa</textarea>
                                        </div>

                                        <!-- Technician Signature -->
                                        <div class="mb-3">
                                            <label class="form-label">
                                                <i class="fas fa-user-check"></i> Kỹ thuật viên thực hiện
                                            </label>
                                            <input type="text" class="form-control" value="${sessionScope.fullName}" readonly>
                                        </div>

                                        <!-- Action Buttons -->
                                        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                            <a href="${pageContext.request.contextPath}/technician/my-tickets" 
                                               class="btn btn-secondary">
                                                <i class="fas fa-arrow-left"></i> Quay lại
                                            </a>
                                            <button type="submit" class="btn btn-success btn-lg">
                                                <i class="fas fa-certificate"></i> Tạo Phiếu Bảo Hành
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Info Panel -->
                            <div class="col-md-4">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-info text-white">
                                        <h5 class="mb-0"><i class="fas fa-info-circle"></i> Hướng dẫn</h5>
                                    </div>
                                    <div class="card-body">
                                        <h6><i class="fas fa-check-circle text-success"></i> Khi nào tạo phiếu BH?</h6>
                                        <p class="small">Tạo phiếu bảo hành sau khi:</p>
                                        <ul class="small">
                                            <li>Hoàn tất sửa chữa</li>
                                            <li>Kiểm tra thiết bị hoạt động tốt</li>
                                            <li>Khách hàng xác nhận nhận lại máy</li>
                                        </ul>

                                        <hr>

                                        <h6><i class="fas fa-exclamation-triangle text-warning"></i> Lưu ý</h6>
                                        <ul class="small">
                                            <li>Thời hạn BH bắt đầu từ ngày tạo phiếu</li>
                                            <li>Ghi rõ linh kiện đã thay</li>
                                            <li>Điều khoản BH phải rõ ràng</li>
                                            <li>Sau khi tạo, ticket sẽ chuyển sang COMPLETED</li>
                                        </ul>
                                    </div>
                                </div>

                                <!-- Warranty History -->
                                <div class="card shadow-sm mt-3">
                                    <div class="card-header bg-secondary text-white">
                                        <h6 class="mb-0"><i class="fas fa-history"></i> Lịch sử BH cũ</h6>
                                    </div>
                                    <div class="card-body">
                                        <c:if test="${not empty productSerial.warrantyStartDate}">
                                            <p class="small mb-1">
                                                <strong>BH trước:</strong><br>
                                                Từ: ${productSerial.warrantyStartDate}<br>
                                                Đến: ${productSerial.warrantyEndDate}
                                            </p>
                                        </c:if>
                                        <c:if test="${empty productSerial.warrantyStartDate}">
                                            <p class="small text-muted">Chưa có lịch sử bảo hành</p>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <!-- No Ticket Selected -->
                        <div class="text-center py-5">
                            <i class="fas fa-clipboard-list fa-5x text-muted mb-3"></i>
                            <h4 class="text-muted">Chưa chọn ticket</h4>
                            <p>Vui lòng chọn ticket từ danh sách "Đơn của tôi" để tạo phiếu bảo hành.</p>
                            <a href="${pageContext.request.contextPath}/technician/my-tickets" class="btn btn-primary">
                                <i class="fas fa-list"></i> Xem danh sách đơn
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
