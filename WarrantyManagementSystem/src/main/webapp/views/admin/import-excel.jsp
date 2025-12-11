<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Import Excel - Hệ Thống Bảo Hành</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
        .upload-area {
            border: 3px dashed #667eea;
            border-radius: 15px;
            padding: 60px 40px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            background: #f8f9ff;
        }
        .upload-area:hover {
            background: #e8ebff;
            border-color: #764ba2;
            transform: scale(1.02);
        }
        .upload-area.dragover {
            background: #d0d8ff;
            border-color: #764ba2;
        }
        .file-info {
            background: #e8f5e9;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .sample-format {
            background: #fff3cd;
            padding: 15px;
            border-radius: 10px;
            border-left: 4px solid #ffc107;
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
                        <i class="fas fa-tools"></i> Admin Panel
                    </h4>
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    
                    <div class="mb-3">
                        <small class="text-white-50">Xin chào,</small>
                        <div class="fw-bold">${sessionScope.fullName}</div>
                    </div>
                    
                    <hr style="border-color: rgba(255,255,255,0.3)">
                    
                    <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/views/admin/import-excel.jsp" class="active">
                        <i class="fas fa-file-excel"></i> Import Excel
                    </a>
                    <a href="${pageContext.request.contextPath}/views/admin/customers.jsp">
                        <i class="fas fa-users"></i> Quản lý khách hàng
                    </a>
                    <a href="${pageContext.request.contextPath}/views/admin/products.jsp">
                        <i class="fas fa-box"></i> Quản lý sản phẩm
                    </a>
                    <a href="${pageContext.request.contextPath}/views/admin/users.jsp">
                        <i class="fas fa-user-cog"></i> Quản lý người dùng
                    </a>
                    <a href="${pageContext.request.contextPath}/views/admin/reports.jsp">
                        <i class="fas fa-chart-bar"></i> Báo cáo
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
                    <h2><i class="fas fa-file-excel text-success"></i> Import dữ liệu Excel</h2>
                    <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>
                </div>

                <!-- Instructions -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <div class="sample-format">
                            <h5><i class="fas fa-info-circle"></i> Hướng dẫn</h5>
                            <p class="mb-2">File Excel cần có các cột sau:</p>
                            <div class="row">
                                <div class="col-md-6">
                                    <strong>Thông tin sản phẩm:</strong>
                                    <ul class="mb-0">
                                        <li>Số seri</li>
                                        <li>Tên sản phẩm</li>
                                        <li>Model</li>
                                        <li>Ngày mua</li>
                                        <li>Thời gian bảo hành (tháng)</li>
                                    </ul>
                                </div>
                                <div class="col-md-6">
                                    <strong>Thông tin khách hàng:</strong>
                                    <ul class="mb-0">
                                        <li>Tên khách hàng</li>
                                        <li>Số điện thoại</li>
                                        <li>Email</li>
                                        <li>Địa chỉ</li>
                                        <li>CMND/CCCD</li>
                                    </ul>
                                </div>
                            </div>
                            <div class="mt-3">
                                <a href="#" class="btn btn-sm btn-warning">
                                    <i class="fas fa-download"></i> Tải file Excel mẫu
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Upload Area -->
                <div class="row">
                    <div class="col-md-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="fas fa-cloud-upload-alt"></i> Tải file Excel</h5>
                            </div>
                            <div class="card-body">
                                <form id="uploadForm" action="${pageContext.request.contextPath}/admin/import-excel" 
                                      method="post" enctype="multipart/form-data">
                                    
                                    <div class="upload-area" id="uploadArea">
                                        <i class="fas fa-cloud-upload-alt fa-5x text-primary mb-3"></i>
                                        <h4>Kéo thả file Excel vào đây</h4>
                                        <p class="text-muted">hoặc</p>
                                        <label for="fileInput" class="btn btn-primary btn-lg">
                                            <i class="fas fa-folder-open"></i> Chọn file
                                        </label>
                                        <input type="file" id="fileInput" name="excelFile" 
                                               accept=".xlsx,.xls" style="display: none;" required>
                                        <p class="text-muted mt-3 mb-0">
                                            <small>Chỉ chấp nhận file .xlsx hoặc .xls (tối đa 10MB)</small>
                                        </p>
                                    </div>

                                    <div id="fileInfo" class="file-info" style="display: none;">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <i class="fas fa-file-excel fa-2x text-success me-3"></i>
                                                <span id="fileName" class="fw-bold"></span>
                                                <span id="fileSize" class="text-muted ms-2"></span>
                                            </div>
                                            <button type="button" class="btn btn-sm btn-danger" id="removeFile">
                                                <i class="fas fa-times"></i> Xóa
                                            </button>
                                        </div>
                                    </div>

                                    <div class="mt-4 text-center">
                                        <button type="submit" class="btn btn-success btn-lg px-5" id="uploadBtn" disabled>
                                            <i class="fas fa-upload"></i> Tải lên và xử lý
                                        </button>
                                    </div>

                                    <div id="progressArea" class="mt-4" style="display: none;">
                                        <div class="progress" style="height: 30px;">
                                            <div id="progressBar" class="progress-bar progress-bar-striped progress-bar-animated" 
                                                 role="progressbar" style="width: 0%">0%</div>
                                        </div>
                                        <p class="text-center mt-2 text-muted">
                                            <span id="progressText">Đang xử lý...</span>
                                        </p>
                                    </div>

                                    <c:if test="${not empty error}">
                                        <div class="alert alert-danger mt-4">
                                            <i class="fas fa-exclamation-circle"></i> ${error}
                                        </div>
                                    </c:if>

                                    <c:if test="${not empty success}">
                                        <div class="alert alert-success mt-4">
                                            <i class="fas fa-check-circle"></i> ${success}
                                        </div>
                                    </c:if>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Uploads -->
                <div class="row mt-4">
                    <div class="col-md-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-secondary text-white">
                                <h5 class="mb-0"><i class="fas fa-history"></i> Lịch sử import</h5>
                            </div>
                            <div class="card-body">
                                <div class="text-center text-muted py-4">
                                    <i class="fas fa-inbox fa-3x mb-3"></i>
                                    <p>Chưa có lịch sử import</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');
        const fileInfo = document.getElementById('fileInfo');
        const fileName = document.getElementById('fileName');
        const fileSize = document.getElementById('fileSize');
        const uploadBtn = document.getElementById('uploadBtn');
        const removeFileBtn = document.getElementById('removeFile');
        const uploadForm = document.getElementById('uploadForm');
        const progressArea = document.getElementById('progressArea');
        const progressBar = document.getElementById('progressBar');
        const progressText = document.getElementById('progressText');

        // Click to upload
        uploadArea.addEventListener('click', () => fileInput.click());

        // Drag and drop
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });

        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });

        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                fileInput.files = files;
                handleFile(files[0]);
            }
        });

        // File input change
        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                handleFile(e.target.files[0]);
            }
        });

        function handleFile(file) {
            const validTypes = ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
                              'application/vnd.ms-excel'];
            const maxSize = 10 * 1024 * 1024; // 10MB

            if (!validTypes.includes(file.type)) {
                alert('Chỉ chấp nhận file Excel (.xlsx, .xls)');
                return;
            }

            if (file.size > maxSize) {
                alert('File không được vượt quá 10MB');
                return;
            }

            fileName.textContent = file.name;
            fileSize.textContent = `(${(file.size / 1024 / 1024).toFixed(2)} MB)`;
            fileInfo.style.display = 'block';
            uploadBtn.disabled = false;
        }

        removeFileBtn.addEventListener('click', () => {
            fileInput.value = '';
            fileInfo.style.display = 'none';
            uploadBtn.disabled = true;
        });

        uploadForm.addEventListener('submit', (e) => {
            e.preventDefault();
            
            progressArea.style.display = 'block';
            uploadBtn.disabled = true;
            
            const formData = new FormData(uploadForm);
            const xhr = new XMLHttpRequest();
            
            xhr.upload.addEventListener('progress', (e) => {
                if (e.lengthComputable) {
                    const percent = (e.loaded / e.total) * 100;
                    progressBar.style.width = percent + '%';
                    progressBar.textContent = Math.round(percent) + '%';
                }
            });
            
            xhr.addEventListener('load', () => {
                if (xhr.status === 200) {
                    progressText.textContent = 'Hoàn thành!';
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                } else {
                    progressText.textContent = 'Có lỗi xảy ra!';
                    progressBar.classList.remove('progress-bar-animated');
                    progressBar.classList.add('bg-danger');
                }
            });
            
            xhr.open('POST', uploadForm.action);
            xhr.send(formData);
        });
    </script>
</body>
</html>
