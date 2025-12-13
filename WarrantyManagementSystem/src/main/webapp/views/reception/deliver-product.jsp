<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bàn Giao Sản Phẩm</title>
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
            min-height: 80px;
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
        .cost-summary {
            background: #fff3cd;
            padding: 15px;
            border-radius: 5px;
            margin: 15px 0;
        }
        .cost-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        .cost-total {
            font-size: 20px;
            font-weight: bold;
            color: #dc3545;
            border-top: 2px solid #dc3545;
            padding-top: 10px;
            margin-top: 10px;
        }
        .payment-status {
            padding: 10px;
            border-radius: 5px;
            margin: 15px 0;
            font-weight: bold;
        }
        .payment-paid {
            background: #d4edda;
            color: #155724;
        }
        .payment-unpaid {
            background: #f8d7da;
            color: #721c24;
        }
        .checkbox-group {
            margin: 15px 0;
        }
        .checkbox-group label {
            display: flex;
            align-items: center;
            cursor: pointer;
        }
        .checkbox-group input[type="checkbox"] {
            width: auto;
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📦 Bàn Giao Sản Phẩm</h1>
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
                <p><strong>Khách Hàng:</strong> ${ticket.customerName}</p>
                <p><strong>SĐT:</strong> ${ticket.customerPhone}</p>
                <p><strong>Vấn Đề:</strong> ${ticket.issueDescription}</p>
                <p><strong>Trạng Thái:</strong> <strong style="color: #28a745;">${ticket.status}</strong></p>
                <p><strong>Ngày Hoàn Thành:</strong> ${ticket.actualCompletionDate}</p>
            </div>

            <!-- Cost Summary -->
            <c:if test="${ticket.totalCost != null && ticket.totalCost > 0}">
                <div class="cost-summary">
                    <h3>💰 Chi Phí Sửa Chữa</h3>
                    <div class="cost-row">
                        <span>Chi phí nhân công:</span>
                        <span>${ticket.laborCost} VNĐ</span>
                    </div>
                    <div class="cost-row">
                        <span>Chi phí linh kiện:</span>
                        <span>${ticket.partsCost} VNĐ</span>
                    </div>
                    <div class="cost-row cost-total">
                        <span>TỔNG CỘNG:</span>
                        <span>${ticket.totalCost} VNĐ</span>
                    </div>
                </div>

                <!-- Payment Status -->
                <div class="payment-status ${ticket.paid ? 'payment-paid' : 'payment-unpaid'}">
                    <c:choose>
                        <c:when test="${ticket.paid}">
                            ✅ ĐÃ THANH TOÁN - Ngày: ${ticket.paymentDate}
                        </c:when>
                        <c:otherwise>
                            ❌ CHƯA THANH TOÁN - Vui lòng thu tiền trước khi bàn giao
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <c:if test="${ticket.totalCost == null || ticket.totalCost == 0}">
                <div class="payment-status payment-paid">
                    🆓 SỬA CHỮA BẢO HÀNH - MIỄN PHÍ
                </div>
            </c:if>
        </div>

        <!-- Delivery Form -->
        <div class="card">
            <h2>✅ Xác Nhận Bàn Giao</h2>
            <form action="${pageContext.request.contextPath}/reception/deliver-product" method="post">
                <input type="hidden" name="ticketId" value="${ticket.ticketId}">

                <!-- Payment Confirmation (if not paid) -->
                <c:if test="${!ticket.paid && ticket.totalCost > 0}">
                    <div class="form-group">
                        <label for="paymentMethod">1️⃣ Phương Thức Thanh Toán *</label>
                        <select id="paymentMethod" name="paymentMethod" required>
                            <option value="">-- Chọn phương thức --</option>
                            <option value="cash">💵 Tiền Mặt</option>
                            <option value="bank_transfer">🏦 Chuyển Khoản</option>
                            <option value="credit_card">💳 Thẻ Tín Dụng</option>
                            <option value="momo">📱 MoMo</option>
                            <option value="zalopay">💙 ZaloPay</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="paymentNotes">2️⃣ Ghi Chú Thanh Toán</label>
                        <textarea id="paymentNotes" name="paymentNotes" 
                                  placeholder="Mã giao dịch, biên lai, ghi chú khác..."></textarea>
                    </div>
                </c:if>

                <!-- Customer Acceptance -->
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="customerAcceptance" required>
                        <span>3️⃣ Khách hàng đã kiểm tra và chấp nhận sản phẩm *</span>
                    </label>
                </div>

                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" name="warrantyCardProvided" required>
                        <span>4️⃣ Đã cung cấp phiếu bảo hành / hóa đơn cho khách hàng *</span>
                    </label>
                </div>

                <!-- Customer Feedback -->
                <div class="form-group">
                    <label for="customerFeedback">5️⃣ Phản Hồi Của Khách Hàng</label>
                    <textarea id="customerFeedback" name="customerFeedback" 
                              placeholder="Ghi chú phản hồi, đánh giá của khách hàng..."></textarea>
                </div>

                <!-- Receiver Information -->
                <div class="form-group">
                    <label for="receiverName">6️⃣ Người Nhận Hàng *</label>
                    <input type="text" id="receiverName" name="receiverName" required
                           value="${ticket.customerName}"
                           placeholder="Tên người đến nhận sản phẩm">
                </div>

                <div class="form-group">
                    <label for="receiverPhone">7️⃣ SĐT Người Nhận *</label>
                    <input type="tel" id="receiverPhone" name="receiverPhone" required
                           value="${ticket.customerPhone}"
                           placeholder="Số điện thoại người nhận">
                </div>

                <div class="form-group">
                    <label for="receiverIdCard">8️⃣ CMND/CCCD Người Nhận</label>
                    <input type="text" id="receiverIdCard" name="receiverIdCard"
                           placeholder="Số CMND/CCCD (nếu có)">
                </div>

                <!-- Delivery Notes -->
                <div class="form-group">
                    <label for="deliveryNotes">9️⃣ Ghi Chú Bàn Giao</label>
                    <textarea id="deliveryNotes" name="deliveryNotes" 
                              placeholder="Các ghi chú khác khi bàn giao sản phẩm..."></textarea>
                </div>

                <div style="margin-top: 30px;">
                    <button type="submit" class="btn btn-primary" 
                            onclick="return confirm('Xác nhận bàn giao sản phẩm cho khách hàng?')">
                        ✅ Hoàn Tất Bàn Giao
                    </button>
                    <a href="${pageContext.request.contextPath}/reception/dashboard" class="btn btn-secondary">
                        ❌ Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
