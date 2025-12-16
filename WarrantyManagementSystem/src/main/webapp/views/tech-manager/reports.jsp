<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Cáo Thống Kê - Tech Manager</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .stat-card {
            border-left: 4px solid;
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .chart-container {
            position: relative;
            height: 300px;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/tech-manager/dashboard">
                Quản Lý Kỹ Thuật
            </a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <span class="navbar-text me-3">${sessionScope.fullName}</span>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/logout">Đăng Xuất</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2">
                <div class="list-group">
                    <a href="${pageContext.request.contextPath}/tech-manager/dashboard" 
                       class="list-group-item list-group-item-action">
                        Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/receive-product" 
                       class="list-group-item list-group-item-action">
                        Tiếp Nhận SP
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/assign-ticket" 
                       class="list-group-item list-group-item-action">
                        Phân Công
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/tickets" 
                       class="list-group-item list-group-item-action">
                        Xem Tickets
                    </a>
                    <a href="${pageContext.request.contextPath}/tech-manager/reports" 
                       class="list-group-item list-group-item-action active">
                        Báo Cáo
                    </a>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-10">
                <!-- Header -->
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">Báo Cáo Thống Kê</h4>
                    </div>
                </div>

                <!-- Total Tickets -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <div class="card stat-card" style="border-left-color: #007bff;">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-2">Tổng Số Tickets</h6>
                                        <h2 class="mb-0">${totalTickets}</h2>
                                    </div>
                                    <div class="text-primary">
                                        <i class="fas fa-ticket-alt fa-3x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Charts Row 1 -->
                <div class="row mb-4">
                    <!-- Status Chart -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">Thống Kê Theo Trạng Thái</h5>
                            </div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="statusChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Priority Chart -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-warning text-dark">
                                <h5 class="mb-0">Thống Kê Theo Độ Ưu Tiên</h5>
                            </div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="priorityChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Charts Row 2 -->
                <div class="row mb-4">
                    <!-- Type Chart -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0">Thống Kê Theo Loại Ticket</h5>
                            </div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="typeChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Technician Workload -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-secondary text-white">
                                <h5 class="mb-0">Khối Lượng Công Việc Kỹ Thuật Viên</h5>
                            </div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="workloadChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Status Details Table -->
                <div class="row">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-header bg-dark text-white">
                                <h5 class="mb-0">Chi Tiết Trạng Thái</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>Trạng Thái</th>
                                                <th>Số Lượng</th>
                                                <th>Phần Trăm</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>Chờ Phân Công</td>
                                                <td>${statusStats.PENDING_ASSIGNMENT}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.PENDING_ASSIGNMENT * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Đã Phân Công</td>
                                                <td>${statusStats.ASSIGNED}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.ASSIGNED * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Đang Chẩn Đoán</td>
                                                <td>${statusStats.IN_DIAGNOSIS}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.IN_DIAGNOSIS * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Chờ Linh Kiện</td>
                                                <td>${statusStats.AWAITING_PARTS}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.AWAITING_PARTS * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Đang Sửa</td>
                                                <td>${statusStats.IN_REPAIR}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.IN_REPAIR * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Kiểm Tra Chất Lượng</td>
                                                <td>${statusStats.QUALITY_CHECK}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.QUALITY_CHECK * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Hoàn Thành</td>
                                                <td>${statusStats.COMPLETED}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.COMPLETED * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Đã Giao</td>
                                                <td>${statusStats.DELIVERED}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.DELIVERED * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Đã Hủy</td>
                                                <td>${statusStats.CANCELLED}</td>
                                                <td>
                                                    <fmt:formatNumber value="${statusStats.CANCELLED * 100.0 / totalTickets}" 
                                                                    maxFractionDigits="1"/>%
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Status Chart
        const statusCtx = document.getElementById('statusChart').getContext('2d');
        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: ['Chờ Phân Công', 'Đã Phân Công', 'Đang Chẩn Đoán', 'Chờ Linh Kiện', 
                         'Đang Sửa', 'Kiểm Tra CL', 'Hoàn Thành', 'Đã Giao', 'Đã Hủy'],
                datasets: [{
                    data: [
                        ${statusStats.PENDING_ASSIGNMENT},
                        ${statusStats.ASSIGNED},
                        ${statusStats.IN_DIAGNOSIS},
                        ${statusStats.AWAITING_PARTS},
                        ${statusStats.IN_REPAIR},
                        ${statusStats.QUALITY_CHECK},
                        ${statusStats.COMPLETED},
                        ${statusStats.DELIVERED},
                        ${statusStats.CANCELLED}
                    ],
                    backgroundColor: [
                        '#ffc107', '#17a2b8', '#6c757d', '#fd7e14',
                        '#007bff', '#6610f2', '#28a745', '#20c997', '#dc3545'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        });

        // Priority Chart
        const priorityCtx = document.getElementById('priorityChart').getContext('2d');
        new Chart(priorityCtx, {
            type: 'bar',
            data: {
                labels: ['Thấp', 'Trung Bình', 'Cao', 'Khẩn Cấp'],
                datasets: [{
                    label: 'Số Lượng Tickets',
                    data: [
                        ${priorityStats.LOW},
                        ${priorityStats.MEDIUM},
                        ${priorityStats.HIGH},
                        ${priorityStats.CRITICAL}
                    ],
                    backgroundColor: ['#28a745', '#ffc107', '#fd7e14', '#dc3545']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        // Type Chart
        const typeCtx = document.getElementById('typeChart').getContext('2d');
        new Chart(typeCtx, {
            type: 'pie',
            data: {
                labels: ['Bảo Hành', 'Trả Phí'],
                datasets: [{
                    data: [
                        ${typeStats.WARRANTY},
                        ${typeStats.PAID_REPAIR}
                    ],
                    backgroundColor: ['#28a745', '#ffc107']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        });

        // Technician Workload Chart
        const workloadCtx = document.getElementById('workloadChart').getContext('2d');
        new Chart(workloadCtx, {
            type: 'horizontalBar',
            data: {
                labels: [
                    <c:forEach var="entry" items="${technicianWorkload}">
                        '${entry.key}',
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Tickets Đang Xử Lý',
                    data: [
                        <c:forEach var="entry" items="${technicianWorkload}">
                            ${entry.value},
                        </c:forEach>
                    ],
                    backgroundColor: '#007bff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: 'y',
                scales: {
                    x: {
                        beginAtZero: true
                    }
                }
            }
        });
    </script>
</body>
</html>
