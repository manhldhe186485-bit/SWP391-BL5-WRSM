<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập Nhật Tiến Độ - Kỹ Thuật Viên</title>
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
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        .timeline {
            position: relative;
            padding-left: 30px;
        }
        .timeline::before {
            content: '';
            position: absolute;
            left: 8px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #dee2e6;
        }
        .timeline-item {
            position: relative;
            margin-bottom: 30px;
            padding-left: 30px;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -26px;
            top: 5px;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            background: #28a745;
            border: 3px solid #fff;
            box-shadow: 0 0 0 2px #28a745;
        }
        .timeline-item.pending::before {
            background: #6c757d;
            box-shadow: 0 0 0 2px #6c757d;
        }
        .form-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
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
                    <a href="${pageContext.request.contextPath}/technician/receive-product">
                        <i class="fas fa-inbox"></i> Tiếp nhận sản phẩm
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/my-tickets">
                        <i class="fas fa-clipboard-list"></i> Đơn của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/request-parts">
                        <i class="fas fa-toolbox"></i> Yêu cầu linh kiện
                    </a>
                    <a href="${pageContext.request.contextPath}/technician/update-progress" class="active">
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
            <main class="col-md-10 ms-sm-auto px-4 py-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-tasks"></i> Cập nhật tiến độ sửa chữa</h2>
                    <a href="${pageContext.request.contextPath}/technician/my-tickets" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>
                </div>

                <!-- Success/Error Messages -->
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

                <div class="row">
                    <!-- Select Ticket -->
                    <div class="col-md-4">
                        <div class="card shadow-sm mb-4">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0"><i class="fas fa-clipboard-list"></i> Chọn đơn</h5>
                            </div>
                            <div class="card-body">
                                <select class="form-select" id="ticketSelect">
                                    <option value="">-- Chọn đơn bảo hành --</option>
                                    <c:forEach var="ticket" items="${myTickets}">
                                        <c:set var="customerName" value="${ticket.customer != null ? ticket.customer.fullName : 'N/A'}" />
                                        <c:set var="serialNumber" value="${ticket.productSerial != null ? ticket.productSerial.serialNumber : 'N/A'}" />
                                        <option value="${ticket.ticketId}"
                                                data-ticket-number="${ticket.ticketNumber}"
                                                data-customer="${customerName}"
                                                data-product="${serialNumber}"
                                                data-issue="${ticket.issueDescription}"
                                                data-status="${ticket.status}">
                                            ${ticket.ticketNumber} - ${serialNumber}
                                        </option>
                                    </c:forEach>
                                </select>
                                
                                <div class="mt-3 d-none" id="ticketInfo">
                                    <hr>
                                    <p class="mb-2"><strong>Khách hàng:</strong> <span id="customerName">-</span></p>
                                    <p class="mb-2"><strong>Sản phẩm:</strong> <span id="productName">-</span></p>
                                    <p class="mb-2"><strong>Lỗi:</strong> <span id="issue">-</span></p>
                                    <p class="mb-0">
                                        <span class="badge bg-warning text-dark" id="status">Đang sửa</span>
                                    </p>
                                </div>
                            </div>
                        </div>

                    </div>

                    <!-- Update Form -->
                    <div class="col-md-8">
                        <div class="card shadow-sm">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="fas fa-plus-circle"></i> Thêm cập nhật mới</h5>
                            </div>
                            <div class="card-body">
                                <form id="updateForm" action="${pageContext.request.contextPath}/technician/update-progress" method="post">
                                    <!-- Hidden field for ticket ID -->
                                    <input type="hidden" name="ticketId" id="hiddenTicketId" value="">
                                    
                                    <div class="mb-3">
                                        <label class="form-label">Trạng thái <span class="text-danger">*</span></label>
                                        <select class="form-select" name="status" required>
                                            <option value="">-- Chọn trạng thái --</option>
                                            <option value="IN_PROGRESS">Đang sửa chữa</option>
                                            <option value="WAITING_PARTS">Chờ linh kiện</option>
                                            <option value="COMPLETED">Hoàn thành</option>
                                        </select>
                                    
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Mô tả chi tiết <span class="text-danger">*</span></label>
                                        <textarea class="form-control" name="description" rows="4" 
                                                  placeholder="Nhập chi tiết về công việc đã thực hiện..." required></textarea>
                                    </div>

                                    <div class="row">
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Linh kiện đã sử dụng (nếu có)</label>
                                        <div class="form-card">
                                            <div id="partsUsed">
                                                <div class="row mb-2">
                                                    <div class="col-md-6">
                                                        <input type="text" class="form-control" placeholder="Tên linh kiện">
                                                    </div>
                                                    <div class="col-md-3">
                                                        <input type="number" class="form-control" placeholder="Số lượng" min="1" value="1">
                                                    </div>
                                                    <div class="col-md-3">
                                                        <button type="button" class="btn btn-danger w-100" onclick="this.parentElement.parentElement.remove()">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                            <button type="button" class="btn btn-sm btn-outline-primary" id="addPartBtn">
                                                <i class="fas fa-plus"></i> Thêm linh kiện
                                            </button>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Hình ảnh đính kèm</label>
                                        <input type="file" class="form-control" name="images" accept="image/*" multiple>
                                        <small class="text-muted">Có thể chọn nhiều hình ảnh</small>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Ghi chú cho khách hàng</label>
                                        <textarea class="form-control" name="customerNote" rows="2" 
                                                  placeholder="Ghi chú này sẽ được khách hàng nhìn thấy..."></textarea>
                                    </div>


                                    <hr>

                                    <div class="d-grid gap-2">
                                        <button type="submit" class="btn btn-success btn-lg">
                                            <i class="fas fa-save"></i> Lưu cập nhật
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Add part button
        document.getElementById('addPartBtn').addEventListener('click', function() {
            const partsDiv = document.getElementById('partsUsed');
            const newPart = document.createElement('div');
            newPart.className = 'row mb-2';
            newPart.innerHTML = `
                <div class="col-md-6">
                    <input type="text" class="form-control" placeholder="Tên linh kiện">
                </div>
                <div class="col-md-3">
                    <input type="number" class="form-control" placeholder="Số lượng" min="1" value="1">
                </div>
                <div class="col-md-3">
                    <button type="button" class="btn btn-danger w-100" onclick="this.parentElement.parentElement.remove()">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
            partsDiv.appendChild(newPart);
        });

        // Form submission
        document.getElementById('updateForm').addEventListener('submit', function(e) {
            const ticketId = document.getElementById('ticketSelect').value;
            
            if (!ticketId) {
                e.preventDefault();
                alert('Vui lòng chọn đơn bảo hành!');
                return false;
            }

            // Set ticket ID to hidden field
            document.getElementById('hiddenTicketId').value = ticketId;
            
            // Validate description
            const description = this.querySelector('textarea[name="description"]').value.trim();
            if (!description) {
                e.preventDefault();
                alert('Vui lòng nhập mô tả chi tiết!');
                return false;
            }
            
            // Show loading
            const btn = this.querySelector('button[type="submit"]');
            if (btn) {
                btn.disabled = true;
                btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';
            }
            
            // Form will submit normally to server
            return true;
        });

        // Auto-select ticket from URL parameter
        window.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const ticketId = urlParams.get('ticketId');
            
            if (ticketId) {
                const ticketSelect = document.getElementById('ticketSelect');
                ticketSelect.value = ticketId;
                
                // Trigger change event to update ticket info
                const event = new Event('change');
                ticketSelect.dispatchEvent(event);
            }
        });

        // Ticket selection
        document.getElementById('ticketSelect').addEventListener('change', function() {
            const ticketInfo = document.getElementById('ticketInfo');
            const selectedOption = this.options[this.selectedIndex];
            
            if (this.value) {
                // Get data from selected option
                const customer = selectedOption.getAttribute('data-customer') || 'N/A';
                const product = selectedOption.getAttribute('data-product') || 'N/A';
                const issue = selectedOption.getAttribute('data-issue') || 'Không có mô tả';
                const status = selectedOption.getAttribute('data-status') || 'UNKNOWN';
                
                // Update display
                document.getElementById('customerName').textContent = customer;
                document.getElementById('productName').textContent = product;
                document.getElementById('issue').textContent = issue;
                
                // Update status badge
                const statusBadge = document.getElementById('status');
                statusBadge.textContent = getStatusText(status);
                statusBadge.className = 'badge ' + getStatusClass(status);
                
                // Show ticket info
                ticketInfo.classList.remove('d-none');
            } else {
                ticketInfo.classList.add('d-none');
            }
        });
        
        // Helper functions for status display
        function getStatusText(status) {
            const statusMap = {
                'PENDING': 'Chờ xử lý',
                'ASSIGNED': 'Đã giao',
                'IN_PROGRESS': 'Đang sửa',
                'WAITING_PARTS': 'Chờ linh kiện',
                'COMPLETED': 'Hoàn thành',
                'DELIVERED': 'Đã giao',
                'CANCELLED': 'Đã hủy'
            };
            return statusMap[status] || status;
        }
        
        function getStatusClass(status) {
            const classMap = {
                'PENDING': 'bg-secondary',
                'ASSIGNED': 'bg-info',
                'IN_PROGRESS': 'bg-warning text-dark',
                'WAITING_PARTS': 'bg-danger',
                'COMPLETED': 'bg-success',
                'DELIVERED': 'bg-primary',
                'CANCELLED': 'bg-dark'
            };
            return classMap[status] || 'bg-secondary';
        }
    </script>
</body>
</html>
