<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chẩn Đoán Kỹ Thuật</title>
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
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
        }
        .ticket-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .ticket-info p {
            margin-bottom: 8px;
        }
        .warranty-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .warranty-valid {
            background: #d4edda;
            color: #155724;
        }
        .warranty-expired {
            background: #f8d7da;
            color: #721c24;
        }
        .cost-summary {
            background: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin-top: 10px;
        }
        .cost-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        .cost-total {
            font-size: 18px;
            font-weight: bold;
            color: #0066cc;
            border-top: 2px solid #0066cc;
            padding-top: 10px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 Chẩn Đoán Kỹ Thuật</h1>
    </div>

    <div class="container">
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <!-- Ticket Info -->
        <div class="card">
            <h2>📋 Thông Tin Ticket</h2>
            <div class="ticket-info">
                <p><strong>Mã Ticket:</strong> ${ticket.ticketCode}</p>
                <p><strong>Serial Number:</strong> ${ticket.productSerialNumber}</p>
                <p><strong>Khách Hàng:</strong> ${ticket.customerName} - ${ticket.customerPhone}</p>
                <p><strong>Vấn Đề:</strong> ${ticket.issueDescription}</p>
                <p><strong>Tình Trạng BH:</strong> 
                    <c:choose>
                        <c:when test="${ticket.ticketType == 'warranty'}">
                            <span class="warranty-badge warranty-valid">Còn BH</span>
                        </c:when>
                        <c:otherwise>
                            <span class="warranty-badge warranty-expired">❌ Hết BH</span>
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>
        </div>

        <!-- Diagnosis Form -->
        <div class="card">
            <h2>📝 Kết Quả Chẩn Đoán</h2>
            <form action="${pageContext.request.contextPath}/technician/create-diagnosis" method="post">
                <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                <!-- Diagnosis Description -->
                <div class="form-group">
                    <label for="diagnosisDescription">1️⃣ Mô Tả Chi Tiết Lỗi *</label>
                    <textarea id="diagnosisDescription" name="diagnosisDescription" required
                              placeholder="Mô tả chi tiết tình trạng lỗi sau khi kiểm tra..."></textarea>
                </div>

                <!-- Root Cause -->
                <div class="form-group">
                    <label for="rootCause">2️⃣ Nguyên Nhân Gốc Rễ *</label>
                    <textarea id="rootCause" name="rootCause" required
                              placeholder="Nguyên nhân gây ra lỗi..."></textarea>
                </div>

                <!-- Repair Solution -->
                <div class="form-group">
                    <label for="repairSolution">3️⃣ Giải Pháp Sửa Chữa *</label>
                    <textarea id="repairSolution" name="repairSolution" required
                              placeholder="Phương pháp sửa chữa dự kiến..."></textarea>
                </div>

                <!-- Required Parts -->
                <div class="form-group">
                    <label for="requiredParts">4️⃣ Linh Kiện Cần Thay Thế</label>
                    <textarea id="requiredParts" name="requiredParts"
                              placeholder="Liệt kê các linh kiện cần thay thế (nếu có)..."></textarea>
                </div>

                <!-- Estimated Time -->
                <div class="form-group">
                    <label for="estimatedHours">5️⃣ Thời Gian Dự Kiến (giờ) *</label>
                    <input type="number" id="estimatedHours" name="estimatedHours" required
                           min="0.5" step="0.5" value="1.0" placeholder="Số giờ">
                </div>

                <!-- Cost Estimation -->
                <div class="form-group">
                    <label for="laborCost">6️⃣ Chi Phí Nhân Công (VNĐ) *</label>
                    <input type="number" id="laborCost" name="laborCost" required
                           min="0" step="1000" value="0" oninput="calculateTotal()"
                           placeholder="Chi phí công sửa chữa">
                </div>

                <div class="form-group">
                    <label for="partsCost">7️⃣ Chi Phí Linh Kiện (VNĐ) *</label>
                    <input type="number" id="partsCost" name="partsCost" required
                           min="0" step="1000" value="0" oninput="calculateTotal()"
                           placeholder="Tổng giá trị linh kiện">
                </div>

                <!-- Cost Summary -->
                <div class="cost-summary">
                    <div class="cost-row">
                        <span>Phí dịch vụ:</span>
                        <span id="displayLaborCost">0 VNĐ</span>
                    </div>
                    <div class="cost-row">
                        <span>Chi phí linh kiện:</span>
                        <span id="displayPartsCost">0 VNĐ</span>
                    </div>
                    <div class="cost-row cost-total">
                        <span>TỔNG CHI PHÍ:</span>
                        <span id="displayTotalCost">0 VNĐ</span>
                    </div>
                </div>

                <!-- Warranty Coverage -->
                <div class="form-group">
                    <label for="repairType">8️⃣ Hình Thức Sửa Chữa *</label>
                    <select id="repairType" name="repairType" required onchange="handleRepairTypeChange()">
                        <option value="warranty" ${ticket.ticketType == 'warranty' ? 'selected' : ''}>
                            🆓 Sửa Chữa Bảo Hành (Miễn Phí)
                        </option>
                        <option value="paid" ${ticket.ticketType != 'warranty' ? 'selected' : ''}>
                            💰 Sửa Chữa Có Phí
                        </option>
                    </select>
                    <small style="color: #666;">
                        <strong>Lưu ý:</strong> 
                        - BH: Chi phí = 0đ
                        <br>- Có phí: Khách hàng sẽ nhận thông báo báo giá
                    </small>
                </div>

                <!-- Customer Notification -->
                <div class="form-group">
                    <label for="customerNotificationMessage">9️⃣ Thông Báo Cho Khách Hàng</label>
                    <textarea id="customerNotificationMessage" name="customerNotificationMessage"
                              placeholder="Nội dung thông báo sẽ gửi cho khách hàng qua email/SMS..."></textarea>
                </div>

                <div style="margin-top: 30px;">
                    <button type="submit" class="btn btn-primary">Hoàn Tất Chẩn Đoán</button>
                    <a href="${pageContext.request.contextPath}/technician/my-tickets" class="btn btn-secondary">
                        ❌ Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function calculateTotal() {
            const laborCost = parseFloat(document.getElementById('laborCost').value) || 0;
            const partsCost = parseFloat(document.getElementById('partsCost').value) || 0;
            const totalCost = laborCost + partsCost;

            document.getElementById('displayLaborCost').textContent = formatCurrency(laborCost);
            document.getElementById('displayPartsCost').textContent = formatCurrency(partsCost);
            document.getElementById('displayTotalCost').textContent = formatCurrency(totalCost);
        }

        function formatCurrency(value) {
            return new Intl.NumberFormat('vi-VN', { 
                style: 'currency', 
                currency: 'VND' 
            }).format(value);
        }

        function handleRepairTypeChange() {
            const repairType = document.getElementById('repairType').value;
            if (repairType === 'warranty') {
                document.getElementById('laborCost').value = 0;
                document.getElementById('partsCost').value = 0;
                calculateTotal();
            }
        }

        // Initialize
        calculateTotal();
    </script>
</body>
</html>
