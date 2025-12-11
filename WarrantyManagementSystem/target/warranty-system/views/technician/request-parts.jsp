<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu Cầu Linh Kiện - Kỹ Thuật Viên</title>
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
        .parts-table td {
            vertical-align: middle;
        }
        .badge-pending { background: #ffc107; color: #000; }
        .badge-approved { background: #28a745; }
        .badge-rejected { background: #dc3545; }
        .badge-completed { background: #6c757d; }
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
                    <a href="${pageContext.request.contextPath}/views/technician/my-tickets.jsp">
                        <i class="fas fa-clipboard-list"></i> Đơn của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/create-warranty-slip.jsp">
                        <i class="fas fa-file-medical"></i> Tạo phiếu BH
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/request-parts.jsp" class="active">
                        <i class="fas fa-toolbox"></i> Yêu cầu linh kiện
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/update-progress.jsp">
                        <i class="fas fa-tasks"></i> Cập nhật tiến độ
                    </a>
                    <a href="${pageContext.request.contextPath}/views/technician/create-invoice.jsp">
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
                    <h2><i class="fas fa-toolbox"></i> Yêu cầu linh kiện từ kho</h2>
                    <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#newRequestModal">
                        <i class="fas fa-plus"></i> Tạo yêu cầu mới
                    </button>
                </div>

                <!-- Tabs -->
                <ul class="nav nav-tabs mb-4" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active" data-bs-toggle="tab" href="#myRequests">
                            <i class="fas fa-list"></i> Yêu cầu của tôi <span class="badge bg-primary ms-1">0</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="tab" href="#newRequest">
                            <i class="fas fa-plus-circle"></i> Tạo mới
                        </a>
                    </li>
                </ul>

                <div class="tab-content">
                    <!-- My Requests Tab -->
                    <div class="tab-pane fade show active" id="myRequests">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0"><i class="fas fa-history"></i> Danh sách yêu cầu</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Mã YC</th>
                                                <th>Đơn BH</th>
                                                <th>Ngày tạo</th>
                                                <th>Số loại LK</th>
                                                <th>Trạng thái</th>
                                                <th>Người duyệt</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td colspan="7" class="text-center text-muted py-4">
                                                    <i class="fas fa-inbox fa-3x mb-3 d-block"></i>
                                                    Chưa có yêu cầu nào
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- New Request Tab -->
                    <div class="tab-pane fade" id="newRequest">
                        <div class="card shadow-sm">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="fas fa-plus-circle"></i> Tạo yêu cầu linh kiện mới</h5>
                            </div>
                            <div class="card-body">
                                <form id="newRequestForm">
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Đơn bảo hành <span class="text-danger">*</span></label>
                                            <select class="form-select" name="ticketId" required>
                                                <option value="">-- Chọn đơn bảo hành --</option>
                                                <!-- Will be populated from backend -->
                                            </select>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Mức độ ưu tiên</label>
                                            <select class="form-select" name="priority">
                                                <option value="LOW">Thấp</option>
                                                <option value="MEDIUM" selected>Trung bình</option>
                                                <option value="HIGH">Cao</option>
                                                <option value="URGENT">Khẩn cấp</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Ghi chú</label>
                                        <textarea class="form-control" name="notes" rows="2" 
                                                  placeholder="Mô tả chi tiết về yêu cầu..."></textarea>
                                    </div>

                                    <hr>

                                    <h5 class="mb-3"><i class="fas fa-boxes"></i> Danh sách linh kiện</h5>
                                    
                                    <div class="table-responsive">
                                        <table class="table table-bordered parts-table">
                                            <thead class="table-light">
                                                <tr>
                                                    <th width="40%">Tên linh kiện <span class="text-danger">*</span></th>
                                                    <th width="15%">Mã LK</th>
                                                    <th width="15%">Số lượng <span class="text-danger">*</span></th>
                                                    <th width="20%">Ghi chú</th>
                                                    <th width="10%"></th>
                                                </tr>
                                            </thead>
                                            <tbody id="partsTableBody">
                                                <tr>
                                                    <td>
                                                        <input type="text" class="form-control" name="partName[]" 
                                                               placeholder="Nhập tên linh kiện" required>
                                                    </td>
                                                    <td>
                                                        <input type="text" class="form-control" name="partCode[]" 
                                                               placeholder="Mã (nếu có)">
                                                    </td>
                                                    <td>
                                                        <input type="number" class="form-control" name="quantity[]" 
                                                               min="1" value="1" required>
                                                    </td>
                                                    <td>
                                                        <input type="text" class="form-control" name="partNote[]" 
                                                               placeholder="Ghi chú">
                                                    </td>
                                                    <td class="text-center">
                                                        <button type="button" class="btn btn-sm btn-danger" onclick="removePartRow(this)">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>

                                    <button type="button" class="btn btn-outline-primary mb-3" onclick="addPartRow()">
                                        <i class="fas fa-plus"></i> Thêm linh kiện
                                    </button>

                                    <hr>

                                    <div class="d-grid gap-2">
                                        <button type="submit" class="btn btn-success btn-lg">
                                            <i class="fas fa-paper-plane"></i> Gửi yêu cầu tới kho
                                        </button>
                                        <button type="reset" class="btn btn-outline-secondary">
                                            <i class="fas fa-redo"></i> Làm mới
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

    <!-- View Request Modal -->
    <div class="modal fade" id="viewRequestModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="fas fa-eye"></i> Chi tiết yêu cầu</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Mã yêu cầu:</strong> PR-2025-0001
                        </div>
                        <div class="col-md-6">
                            <strong>Trạng thái:</strong> 
                            <span class="badge badge-pending">Chờ duyệt</span>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Đơn bảo hành:</strong> WR-2025-0001
                        </div>
                        <div class="col-md-6">
                            <strong>Ngày tạo:</strong> 10/12/2025 14:30
                        </div>
                    </div>
                    <hr>
                    <h6>Danh sách linh kiện:</h6>
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Tên linh kiện</th>
                                    <th>Mã</th>
                                    <th>SL yêu cầu</th>
                                    <th>SL duyệt</th>
                                    <th>Ghi chú</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td colspan="5" class="text-center text-muted">Không có dữ liệu</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function addPartRow() {
            const tbody = document.getElementById('partsTableBody');
            const newRow = document.createElement('tr');
            newRow.innerHTML = `
                <td>
                    <input type="text" class="form-control" name="partName[]" 
                           placeholder="Nhập tên linh kiện" required>
                </td>
                <td>
                    <input type="text" class="form-control" name="partCode[]" 
                           placeholder="Mã (nếu có)">
                </td>
                <td>
                    <input type="number" class="form-control" name="quantity[]" 
                           min="1" value="1" required>
                </td>
                <td>
                    <input type="text" class="form-control" name="partNote[]" 
                           placeholder="Ghi chú">
                </td>
                <td class="text-center">
                    <button type="button" class="btn btn-sm btn-danger" onclick="removePartRow(this)">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(newRow);
        }

        function removePartRow(btn) {
            const tbody = document.getElementById('partsTableBody');
            if (tbody.children.length > 1) {
                btn.closest('tr').remove();
            } else {
                alert('Phải có ít nhất 1 linh kiện!');
            }
        }

        document.getElementById('newRequestForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const btn = this.querySelector('button[type="submit"]');
            const originalText = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang gửi...';

            setTimeout(() => {
                alert('Đã gửi yêu cầu thành công!\nKho sẽ xử lý yêu cầu của bạn.');
                btn.disabled = false;
                btn.innerHTML = originalText;
                this.reset();
                
                // Switch to my requests tab
                document.querySelector('a[href="#myRequests"]').click();
            }, 1500);
        });
    </script>
</body>
</html>
