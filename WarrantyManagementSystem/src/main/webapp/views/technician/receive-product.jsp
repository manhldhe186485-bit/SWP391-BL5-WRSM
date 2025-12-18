<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tiếp Nhận Sản Phẩm Bảo Hành và Sửa chữa</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
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
        .card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
            border: none;
        }
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0 !important;
            padding: 20px;
            margin: -30px -30px 20px -30px;
        }
        h2 {
            color: white;
            margin-bottom: 0;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #495057;
            font-weight: 600;
        }
        input, textarea, select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
        }
        input:focus, textarea:focus, select:focus {
            border-color: #667eea;
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        textarea {
            min-height: 100px;
            resize: vertical;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            margin-right: 10px;
            transition: all 0.3s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .serial-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-top: 10px;
        }
        .serial-info.warranty-valid {
            border-left: 4px solid #28a745;
        }
        .serial-info.warranty-expired {
            border-left: 4px solid #dc3545;
        }
        .warranty-status {
            font-weight: bold;
            font-size: 16px;
        }
        .warranty-valid .warranty-status {
            color: #28a745;
        }
        .warranty-expired .warranty-status {
            color: #dc3545;
        }
        #checkSerialBtn {
            margin-top: 10px;
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
                    <a href="${pageContext.request.contextPath}/technician/receive-product" class="active">
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
            <div class="col-md-10 content-area">
                <div class="mb-4">
                    <h3><i class="fas fa-inbox me-2"></i>Tiếp Nhận Sản Phẩm Bảo Hành và Sửa Chữa</h3>
                    <p class="text-muted">Tạo phiếu tiếp nhận sản phẩm bảo hành/sửa chữa từ khách hàng</p>
                </div>
                <c:if test="${not empty message}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i>${message}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="card">
                    <div class="card-header">
                        <h2 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Thông Tin Tiếp Nhận</h2>
                    </div>
            <form action="${pageContext.request.contextPath}/technician/receive-product" method="post" enctype="multipart/form-data">
                
                <!-- Step 1: Check Serial Number -->
                <div class="form-group">
                    <label for="serialNumber">Số Serial Sản Phẩm *</label>
                    <input type="text" id="serialNumber" name="serialNumber" required 
                           value="${serialNumber}" placeholder="Nhập số serial để kiểm tra">
                    <button type="button" class="btn btn-secondary" id="checkSerialBtn" 
                            onclick="checkSerial()">Kiểm Tra Serial</button>
                </div>

                <!-- Serial Not Found - Customer Info Form -->
                <div id="customerInfoSection" style="display: none; border: 2px solid #ffc107; padding: 20px; border-radius: 8px; background: #fff3cd; margin-bottom: 20px;">
                    <h4 style="color: #856404; margin-bottom: 15px;">⚠️ Serial không tồn tại - Nhập thông tin khách hàng</h4>
                    
                    <div class="form-group">
                        <label for="customerName">Tên Khách Hàng *</label>
                        <input type="text" id="customerName" name="customerName" 
                               placeholder="Nhập tên khách hàng">
                    </div>
                    
                    <div class="form-group">
                        <label for="customerPhone">Số Điện Thoại *</label>
                        <input type="tel" id="customerPhone" name="customerPhone" 
                               placeholder="Nhập số điện thoại khách hàng">
                    </div>
                    
                    <div class="form-group">
                        <label for="customerEmail">Email (tùy chọn)</label>
                        <input type="email" id="customerEmail" name="customerEmail" 
                               placeholder="Nhập email khách hàng">
                    </div>
                    
                    <input type="hidden" id="isWalkIn" name="isWalkIn" value="false">
                </div>

                <!-- Serial Info Display (Found) -->
                <c:if test="${not empty serialInfo}">
                    <div class="serial-info ${serialInfo.underWarranty ? 'warranty-valid' : 'warranty-expired'}">
                        <p class="warranty-status">
                            ${serialInfo.underWarranty ? 'CÒN BẢO HÀNH' : 'HẾT BẢO HÀNH'}
                        </p>
                        <p><strong>Sản phẩm:</strong> ${serialInfo.productName}</p>
                        <p><strong>Khách hàng:</strong> ${serialInfo.customerName}</p>
                        <p><strong>SĐT:</strong> ${serialInfo.customerPhone}</p>
                        <p><strong>Ngày mua:</strong> ${serialInfo.purchaseDate}</p>
                        <p><strong>BH từ:</strong> ${serialInfo.warrantyStartDate} <strong>đến:</strong> ${serialInfo.warrantyEndDate}</p>
                    </div>
                </c:if>

                <!-- Step 2: Issue Description -->
                <div class="form-group">
                    <label for="issueDescription">Mô Tả Lỗi / Vấn Đề *</label>
                    <textarea id="issueDescription" name="issueDescription" required 
                              placeholder="Mô tả chi tiết vấn đề của sản phẩm...">${issueDescription}</textarea>
                </div>

                <!-- Step 4: Photos -->
                <div class="form-group">
                    <label for="photo">Ảnh Sản Phẩm (tùy chọn)</label>
                    <input type="file" id="photo" name="photo" accept="image/*">
                    <small style="color: #666;">Hỗ trợ JPG, PNG (Max 5MB)</small>
                </div>

                <!-- Step 5: Notes -->
                <div class="form-group">
                    <label for="notes">Ghi Chú Thêm</label>
                    <textarea id="notes" name="notes" 
                              placeholder="Các ghi chú khác...">${notes}</textarea>
                </div>

                    <div style="margin-top: 30px;">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <i class="fas fa-save me-2"></i>Tạo Phiếu Bảo Hành
                        </button>
                        <a href="${pageContext.request.contextPath}/technician/dashboard" class="btn btn-secondary">
                            <i class="fas fa-times me-2"></i>Hủy
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function checkSerial() {
            const serialNumber = document.getElementById('serialNumber').value;
            if (!serialNumber) {
                alert('Vui lòng nhập số serial!');
                return;
            }
            
            // Call AJAX to check serial
            fetch('${pageContext.request.contextPath}/technician/check-serial?serialNumber=' + encodeURIComponent(serialNumber))
                .then(response => response.json())
                .then(data => {
                    if (data.found) {
                        // Serial tồn tại - hiển thị thông tin
                        alert('✅ Tìm thấy sản phẩm!\nKhách hàng: ' + data.customerName + 
                              '\nTrạng thái: ' + (data.underWarranty ? 'Còn bảo hành' : 'Hết bảo hành'));
                        
                        // Ẩn form customer info
                        document.getElementById('customerInfoSection').style.display = 'none';
                        document.getElementById('isWalkIn').value = 'false';
                        
                        // Đổi button về bảo hành
                        const submitBtn = document.getElementById('submitBtn');
                        submitBtn.innerHTML = '<i class="fas fa-save me-2"></i>Tạo Phiếu Bảo Hành';
                        submitBtn.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
                        
                        // Không bắt buộc customer info
                        document.getElementById('customerName').removeAttribute('required');
                        document.getElementById('customerPhone').removeAttribute('required');
                        
                    } else {
                        // Serial không tồn tại - hiển thị form nhập customer
                        alert('⚠️ Không tìm thấy serial trong hệ thống!\nVui lòng nhập thông tin khách hàng để tạo phiếu sửa chữa.');
                        
                        // Hiển thị form customer info
                        document.getElementById('customerInfoSection').style.display = 'block';
                        document.getElementById('isWalkIn').value = 'true';
                        
                        // Đổi button thành sửa chữa
                        const submitBtn = document.getElementById('submitBtn');
                        submitBtn.innerHTML = '<i class="fas fa-save me-2"></i>Tạo Phiếu Sửa Chữa';
                        submitBtn.style.background = 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)';
                        
                        // Bắt buộc nhập customer info
                        document.getElementById('customerName').setAttribute('required', 'required');
                        document.getElementById('customerPhone').setAttribute('required', 'required');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi kiểm tra serial!');
                });
        }
        
        // Auto-show PDF download modal if success
        <c:if test="${param.success == 'true' && sessionScope.showPdfDownload}">
            window.addEventListener('DOMContentLoaded', function() {
                const modal = new bootstrap.Modal(document.getElementById('pdfDownloadModal'));
                modal.show();
            });
        </c:if>
    </script>

    <!-- PDF Download Modal -->
    <c:if test="${sessionScope.showPdfDownload}">
        <div class="modal fade" id="pdfDownloadModal" tabindex="-1" aria-labelledby="pdfDownloadModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="pdfDownloadModalLabel">
                            <i class="fas fa-check-circle me-2"></i>Tạo phiếu thành công!
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center py-4">
                        <i class="fas fa-file-pdf fa-5x text-danger mb-3"></i>
                        <h4 class="mb-3">${sessionScope.message}</h4>
                        <p class="text-muted mb-4">
                            Bạn có thể tải xuống phiếu tiếp nhận PDF để in và giao cho khách hàng.
                        </p>
                        <div class="d-grid gap-2">
                            <a href="${pageContext.request.contextPath}/technician/download-receipt?ticketId=${sessionScope.newTicketId}" 
                               class="btn btn-danger btn-lg" target="_blank">
                                <i class="fas fa-download me-2"></i>Tải xuống phiếu PDF
                            </a>
                            <a href="${pageContext.request.contextPath}/technician/dashboard" 
                               class="btn btn-outline-secondary">
                                <i class="fas fa-home me-2"></i>Về Dashboard
                            </a>
                            <button type="button" class="btn btn-outline-primary" data-bs-dismiss="modal">
                                <i class="fas fa-plus me-2"></i>Tiếp tục tiếp nhận
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <c:remove var="showPdfDownload" scope="session"/>
        <c:remove var="newTicketId" scope="session"/>
        <c:remove var="message" scope="session"/>
    </c:if>
</body>
</html>
