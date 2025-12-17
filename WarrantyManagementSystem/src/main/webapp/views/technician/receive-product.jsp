<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tiếp Nhận Sản Phẩm Bảo Hành</title>
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
            max-width: 900px;
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
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: 600;
        }
        input, textarea, select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        textarea {
            min-height: 100px;
            resize: vertical;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            margin-right: 10px;
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
    <div class="header">
        <h1>Tiếp Nhận Sản Phẩm Bảo Hành</h1>
    </div>

    <div class="container">
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <div class="card">
            <h2>Thông Tin Tiếp Nhận</h2>
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

                <!-- Step 3: Priority -->
                <div class="form-group">
                    <label for="priority">Độ Ưu Tiên *</label>
                    <select id="priority" name="priority" required>
                        <option value="LOW" ${priority == 'LOW' ? 'selected' : ''}>Thấp</option>
                        <option value="MEDIUM" ${priority == 'MEDIUM' ? 'selected' : ''} selected>Trung Bình</option>
                        <option value="HIGH" ${priority == 'HIGH' ? 'selected' : ''}>Cao</option>
                        <option value="URGENT" ${priority == 'URGENT' ? 'selected' : ''}>Khẩn Cấp</option>
                    </select>
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
                    <button type="submit" class="btn btn-primary" id="submitBtn">Tạo Phiếu Bảo Hành</button>
                    <a href="${pageContext.request.contextPath}/technician/dashboard" class="btn btn-secondary">
                        Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>

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
                        submitBtn.textContent = 'Tạo Phiếu Bảo Hành';
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
                        submitBtn.textContent = 'Tạo Phiếu Sửa Chữa';
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
    </script>
</body>
</html>
