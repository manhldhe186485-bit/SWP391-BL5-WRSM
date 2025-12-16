<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Người Dùng</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px 40px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .container { max-width: 1400px; margin: 30px auto; padding: 0 20px; }
        .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
        h2 { color: #333; margin-bottom: 20px; }
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; }
        .alert-danger { background: #f8d7da; color: #721c24; }
        .btn { padding: 8px 16px; border: none; border-radius: 5px; font-size: 14px; cursor: pointer; margin-right: 5px; text-decoration: none; display: inline-block; }
        .btn-primary { background: #667eea; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; color: #666; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: 600; color: #555; }
        input, select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; }
        .modal-content { background: white; margin: 50px auto; padding: 30px; max-width: 600px; border-radius: 10px; }
        .role-badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .role-ADMIN { background: #ff4757; color: white; }
        .role-TECH_MANAGER { background: #3742fa; color: white; }
        .role-TECHNICIAN { background: #ffa502; color: white; }
        .role-WAREHOUSE { background: #2ed573; color: white; }
        .role-CUSTOMER { background: #5f27cd; color: white; }
        .status-active { color: #28a745; font-weight: bold; }
        .status-inactive { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>👥 Quản Lý Người Dùng Hệ Thống</h1>
    </div>

    <div class="container">
        <c:if test="${not empty sessionScope.message}">
            <div class="alert alert-success">${sessionScope.message}</div>
            <c:remove var="message" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger">${sessionScope.error}</div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2>📋 Danh Sách Người Dùng (${users.size()})</h2>
                <button class="btn btn-primary" onclick="showCreateModal()">➕ Thêm Người Dùng</button>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tên Đăng Nhập</th>
                        <th>Họ Tên</th>
                        <th>Email</th>
                        <th>SĐT</th>
                        <th>Vai Trò</th>
                        <th>Trạng Thái</th>
                        <th>Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${users}" var="user">
                        <tr>
                            <td>${user.userId}</td>
                            <td><strong>${user.username}</strong></td>
                            <td>${user.fullName}</td>
                            <td>${user.email}</td>
                            <td>${user.phone}</td>
                            <td><span class="role-badge role-${user.role}">${user.role}</span></td>
                            <td class="${user.active ? 'status-active' : 'status-inactive'}">
                                ${user.active ? 'Active' : 'Inactive'}
                            </td>
                            <td>
                                <button class="btn btn-warning" onclick="showEditModal(${user.userId})">Sửa</button>
                                <form action="${pageContext.request.contextPath}/admin/users?action=toggle-status&userId=${user.userId}" 
                                      method="get" style="display: inline;">
                                    <button type="submit" class="btn ${user.active ? 'btn-danger' : 'btn-success'}">
                                        ${user.active ? 'Vô hiệu hóa' : 'Kích hoạt'}
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary">⬅️ Quay Lại Dashboard</a>
    </div>

    <!-- Create User Modal -->
    <div id="createModal" class="modal">
        <div class="modal-content">
            <h2>➕ Thêm Người Dùng Mới</h2>
            <form action="${pageContext.request.contextPath}/admin/users?action=create" method="post">
                <div class="form-group">
                    <label>Tên Đăng Nhập *</label>
                    <input type="text" name="username" required>
                </div>
                <div class="form-group">
                    <label>Mật Khẩu *</label>
                    <input type="password" name="password" required minlength="6">
                </div>
                <div class="form-group">
                    <label>Họ Tên *</label>
                    <input type="text" name="fullName" required>
                </div>
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email" required>
                </div>
                <div class="form-group">
                    <label>Số Điện Thoại</label>
                    <input type="tel" name="phone">
                </div>
                <div class="form-group">
                    <label>Vai Trò *</label>
                    <select name="role" required>
                        <option value="ADMIN">Admin</option>
                        <option value="TECH_MANAGER">Quản Lý Kỹ Thuật</option>
                        <option value="TECHNICIAN">Kỹ Thuật Viên</option>
                        <option value="WAREHOUSE">Kho</option>
                        <option value="CUSTOMER">Khách Hàng</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Tạo</button>
                <button type="button" class="btn btn-secondary" onclick="hideModal('createModal')">❌ Hủy</button>
            </form>
        </div>
    </div>

    <script>
        function showCreateModal() {
            document.getElementById('createModal').style.display = 'block';
        }
        function showEditModal(userId) {
            window.location.href = '${pageContext.request.contextPath}/admin/users?action=edit&userId=' + userId;
        }
        function hideModal(id) {
            document.getElementById(id).style.display = 'none';
        }
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        }
    </script>
</body>
</html>
