<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Phiếu Thanh Toán - Hệ Thống Bảo Hành</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(180deg, #1e3c72 0%, #2a5298 100%);
        }
        .nav-link {
            color: rgba(255,255,255,0.8);
            padding: 12px 20px;
            margin: 4px 0;
            border-radius: 8px;
            transition: all 0.3s;
        }
        .nav-link:hover {
            background: rgba(255,255,255,0.1);
            color: white;
        }
        .nav-link.active {
            background: rgba(255,255,255,0.2);
            color: white;
            font-weight: 600;
            border-left: 4px solid #fff;
        }
        .content-area {
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0 !important;
            padding: 20px;
        }
        .form-label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
        }
        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        .cost-display {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
        }
        .cost-label {
            font-size: 14px;
            color: #6c757d;
            margin-bottom: 5px;
        }
        .cost-value {
            font-size: 24px;
            font-weight: bold;
            color: #495057;
        }
        .total-cost {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-create {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 12px 40px;
            font-weight: 600;
        }
        .btn-create:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 sidebar p-0">
                <div class="p-3">
                    <h4 class="text-white text-center mb-4">
                        <i class="fas fa-tools"></i> Kỹ Thuật Viên
                    </h4>
                    <nav class="nav flex-column">
                        <a class="nav-link" href="${pageContext.request.contextPath}/technician/dashboard">
                            <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/technician/receive-product">
                            <i class="fas fa-box-open me-2"></i>Nhận sản phẩm
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/technician/my-tickets">
                            <i class="fas fa-ticket-alt me-2"></i>Đơn của tôi
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/technician/request-parts">
                            <i class="fas fa-cogs me-2"></i>Yêu cầu linh kiện
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/technician/update-progress">
                            <i class="fas fa-tasks me-2"></i>Cập nhật tiến độ
                        </a>
                        <a class="nav-link active" href="${pageContext.request.contextPath}/technician/create-invoice">
                            <i class="fas fa-file-invoice-dollar me-2"></i>Tạo phiếu thanh toán
                        </a>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 content-area p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-file-invoice-dollar me-2"></i>Tạo Phiếu Thanh Toán</h2>
                    <div>
                        <span class="me-3">Xin chào, <strong>${sessionScope.user.fullName}</strong></span>
                        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">
                            <i class="fas fa-sign-out-alt"></i> Đăng xuất
                        </a>
                    </div>
                </div>

                <!-- Success/Error Messages -->
                <c:if test="${param.success == 'true'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i>Tạo phiếu thanh toán thành công!
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'true'}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>Có lỗi xảy ra khi tạo phiếu thanh toán!
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Invoice Form -->
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Thông Tin Phiếu Thanh Toán</h4>
                    </div>
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/technician/create-invoice" method="post" id="invoiceForm">
                            <input type="hidden" name="action" value="create">
                            
                            <div class="row">
                                <!-- Ticket Selection -->
                                <div class="col-md-6 mb-4">
                                    <label for="ticketId" class="form-label">
                                        <i class="fas fa-ticket-alt me-2"></i>Chọn đơn bảo hành
                                    </label>
                                    <select class="form-select" id="ticketId" name="ticketId" required>
                                        <option value="">-- Chọn đơn đã hoàn thành --</option>
                                        <c:choose>
                                            <c:when test="${empty completedTickets}">
                                                <option value="" disabled>Không có đơn nào</option>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="ticket" items="${completedTickets}">
                                                    <option value="${ticket.ticketId}" 
                                                            data-ticket-number="${ticket.ticketNumber}"
                                                            data-product="${ticket.productName}"
                                                            data-customer="${ticket.customerName}">
                                                        ${ticket.ticketNumber} - ${ticket.productName}
                                                    </option>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </select>
                                    <small class="text-muted">Chỉ hiển thị đơn đã hoàn tất sửa chữa</small>
                                    <!-- Debug info -->
                                    <c:if test="${not empty completedTickets}">
                                        <small class="text-success d-block">Đã tải ${fn:length(completedTickets)} đơn</small>
                                    </c:if>
                                    <c:if test="${empty completedTickets}">
                                        <small class="text-danger d-block">Không có đơn hoàn thành nào</small>
                                    </c:if>
                                </div>

                                <!-- Ticket Info Display -->
                                <div class="col-md-6 mb-4">
                                    <div class="cost-display" style="background: #e7f3ff;">
                                        <div class="cost-label"><i class="fas fa-info-circle me-2"></i>Thông tin đơn hàng</div>
                                        <div id="ticketInfo" class="mt-2">
                                            <small class="text-muted">Chọn đơn để xem thông tin</small>
                                        </div>
                                    </div>
                                </div>

                                <!-- Labor Cost -->
                                <div class="col-md-6 mb-4">
                                    <label for="laborCost" class="form-label">
                                        <i class="fas fa-user-cog me-2"></i>Chi phí nhân công (VNĐ)
                                    </label>
                                    <input type="number" class="form-control" id="laborCost" name="laborCost" 
                                           step="1000" min="0" value="0" required>
                                    <small class="text-muted">Nhập chi phí công sửa chữa</small>
                                </div>

                                <!-- Parts Cost -->
                                <div class="col-md-6 mb-4">
                                    <label for="partsCost" class="form-label">
                                        <i class="fas fa-cogs me-2"></i>Chi phí linh kiện (VNĐ)
                                    </label>
                                    <input type="number" class="form-control" id="partsCost" name="partsCost" 
                                           step="1000" min="0" value="0" required>
                                    <small class="text-muted">Nhập tổng chi phí linh kiện thay thế</small>
                                </div>

                                <!-- Notes -->
                                <div class="col-12 mb-4">
                                    <label for="notes" class="form-label">
                                        <i class="fas fa-sticky-note me-2"></i>Ghi chú
                                    </label>
                                    <textarea class="form-control" id="notes" name="notes" rows="3" 
                                              placeholder="Ghi chú về phiếu thanh toán..."></textarea>
                                </div>

                                <!-- Cost Summary -->
                                <div class="col-12 mb-4">
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="cost-display">
                                                <div class="cost-label">Chi phí nhân công</div>
                                                <div class="cost-value" id="displayLaborCost">0 ₫</div>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="cost-display">
                                                <div class="cost-label">Chi phí linh kiện</div>
                                                <div class="cost-value" id="displayPartsCost">0 ₫</div>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="cost-display total-cost">
                                                <div class="cost-label">TỔNG CỘNG</div>
                                                <div class="cost-value" id="displayTotalCost">0 ₫</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Submit Button -->
                                <div class="col-12 text-center">
                                    <button type="submit" class="btn btn-primary btn-lg btn-create">
                                        <i class="fas fa-save me-2"></i>Tạo Phiếu Thanh Toán
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Format currency
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(amount);
        }

        // Update ticket info when selection changes
        document.getElementById('ticketId').addEventListener('change', function() {
            const option = this.options[this.selectedIndex];
            const ticketInfo = document.getElementById('ticketInfo');
            
            if (this.value) {
                const ticketNumber = option.getAttribute('data-ticket-number');
                const product = option.getAttribute('data-product');
                const customer = option.getAttribute('data-customer');
                
                ticketInfo.innerHTML = `
                    <div><strong>Mã đơn:</strong> ${ticketNumber}</div>
                    <div><strong>Sản phẩm:</strong> ${product}</div>
                    <div><strong>Khách hàng:</strong> ${customer}</div>
                `;
            } else {
                ticketInfo.innerHTML = '<small class="text-muted">Chọn đơn để xem thông tin</small>';
            }
        });

        // Update cost displays
        function updateCostDisplays() {
            const laborCost = parseFloat(document.getElementById('laborCost').value) || 0;
            const partsCost = parseFloat(document.getElementById('partsCost').value) || 0;
            const totalCost = laborCost + partsCost;

            document.getElementById('displayLaborCost').textContent = formatCurrency(laborCost);
            document.getElementById('displayPartsCost').textContent = formatCurrency(partsCost);
            document.getElementById('displayTotalCost').textContent = formatCurrency(totalCost);
        }

        document.getElementById('laborCost').addEventListener('input', updateCostDisplays);
        document.getElementById('partsCost').addEventListener('input', updateCostDisplays);

        // Form validation
        document.getElementById('invoiceForm').addEventListener('submit', function(e) {
            const ticketId = document.getElementById('ticketId').value;
            const laborCost = parseFloat(document.getElementById('laborCost').value) || 0;
            const partsCost = parseFloat(document.getElementById('partsCost').value) || 0;

            if (!ticketId) {
                e.preventDefault();
                alert('Vui lòng chọn đơn bảo hành!');
                return false;
            }

            if (laborCost === 0 && partsCost === 0) {
                e.preventDefault();
                alert('Chi phí nhân công hoặc chi phí linh kiện phải lớn hơn 0!');
                return false;
            }

            return confirm('Bạn có chắc chắn muốn tạo phiếu thanh toán này?');
        });
    </script>
</body>
</html>
