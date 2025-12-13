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
        <h1>📥 Tiếp Nhận Sản Phẩm Bảo Hành</h1>
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
            <form action="${pageContext.request.contextPath}/tech-manager/receive-product" method="post" enctype="multipart/form-data">
                
                <!-- Step 1: Check Serial Number -->
                <div class="form-group">
                    <label for="serialNumber">1️⃣ Số Serial Sản Phẩm *</label>
                    <input type="text" id="serialNumber" name="serialNumber" required 
                           value="${serialNumber}" placeholder="Nhập số serial để kiểm tra">
                    <button type="button" class="btn btn-secondary" id="checkSerialBtn" 
                            onclick="checkSerial()">🔍 Kiểm Tra Serial</button>
                </div>

                <!-- Serial Info Display -->
                <c:if test="${not empty serialInfo}">
                    <div class="serial-info ${serialInfo.underWarranty ? 'warranty-valid' : 'warranty-expired'}">
                        <p class="warranty-status">
                            ${serialInfo.underWarranty ? '✅ CÒN BẢO HÀNH' : '❌ HẾT BẢO HÀNH'}
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
                    <label for="issueDescription">2️⃣ Mô Tả Lỗi / Vấn Đề *</label>
                    <textarea id="issueDescription" name="issueDescription" required 
                              placeholder="Mô tả chi tiết vấn đề của sản phẩm...">${issueDescription}</textarea>
                </div>

                <!-- Step 3: Initial Diagnosis -->
                <div class="form-group">
                    <label for="initialDiagnosis">3️⃣ Chẩn Đoán Ban Đầu</label>
                    <textarea id="initialDiagnosis" name="initialDiagnosis" 
                              placeholder="Ghi chú sơ bộ về tình trạng sản phẩm...">${initialDiagnosis}</textarea>
                </div>

                <!-- Step 4: Priority -->
                <div class="form-group">
                    <label for="priority">4️⃣ Độ Ưu Tiên *</label>
                    <select id="priority" name="priority" required>
                        <option value="low" ${priority == 'low' ? 'selected' : ''}>🟢 Thấp</option>
                        <option value="medium" ${priority == 'medium' ? 'selected' : ''}>🟡 Trung Bình</option>
                        <option value="high" ${priority == 'high' ? 'selected' : ''}>🔴 Cao</option>
                        <option value="urgent" ${priority == 'urgent' ? 'selected' : ''}>🚨 Khẩn Cấp</option>
                    </select>
                </div>

                <!-- Step 5: Photos -->
                <div class="form-group">
                    <label for="photos">5️⃣ Ảnh Sản Phẩm (tùy chọn)</label>
                    <input type="file" id="photos" name="photos" multiple accept="image/*">
                    <small style="color: #666;">Có thể chọn nhiều ảnh. Hỗ trợ JPG, PNG, GIF</small>
                </div>

                <!-- Step 6: Notes -->
                <div class="form-group">
                    <label for="notes">6️⃣ Ghi Chú Thêm</label>
                    <textarea id="notes" name="notes" 
                              placeholder="Các ghi chú khác...">${notes}</textarea>
                </div>

                <div style="margin-top: 30px;">
                    <button type="submit" class="btn btn-primary">✅ Tạo Ticket Bảo Hành</button>
                    <a href="${pageContext.request.contextPath}/tech-manager/dashboard" class="btn btn-secondary">
                        ❌ Hủy
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
            window.location.href = '${pageContext.request.contextPath}/tech-manager/receive-product?action=check&serialNumber=' + encodeURIComponent(serialNumber);
        }
    </script>
</body>
</html>
