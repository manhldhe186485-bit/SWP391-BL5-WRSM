<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Sản Phẩm</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px 40px; }
        .container { max-width: 1400px; margin: 30px auto; padding: 0 20px; }
        .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
        h2 { color: #333; margin-bottom: 20px; }
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; }
        .alert-danger { background: #f8d7da; color: #721c24; }
        .btn { padding: 8px 16px; border: none; border-radius: 5px; font-size: 14px; cursor: pointer; margin-right: 5px; text-decoration: none; display: inline-block; }
        .btn-primary { background: #667eea; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; color: #666; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: 600; color: #555; }
        input, textarea, select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        textarea { min-height: 80px; resize: vertical; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; }
        .modal-content { background: white; margin: 50px auto; padding: 30px; max-width: 700px; border-radius: 10px; max-height: 80vh; overflow-y: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📦 Quản Lý Sản Phẩm</h1>
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
                <h2>📋 Danh Sách Sản Phẩm (${products.size()})</h2>
                <button class="btn btn-primary" onclick="showCreateModal()">➕ Thêm Sản Phẩm</button>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Mã SP</th>
                        <th>Tên Sản Phẩm</th>
                        <th>Danh Mục</th>
                        <th>Thương Hiệu</th>
                        <th>Model</th>
                        <th>BH (tháng)</th>
                        <th>Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty products}">
                        <tr><td colspan="8" style="text-align: center; color: #999; padding: 40px;">Chưa có sản phẩm nào</td></tr>
                    </c:if>
                    <c:forEach items="${products}" var="product">
                        <tr>
                            <td>${product.productId}</td>
                            <td><strong>${product.productCode}</strong></td>
                            <td>${product.name}</td>
                            <td>${product.category}</td>
                            <td>${product.brand}</td>
                            <td>${product.model}</td>
                            <td>${product.warrantyMonths}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/products?action=edit&productId=${product.productId}" 
                                   class="btn btn-warning">✏️ Sửa</a>
                                <a href="${pageContext.request.contextPath}/admin/products?action=delete&productId=${product.productId}" 
                                   class="btn btn-danger" onclick="return confirm('Xác nhận xóa sản phẩm?')">🗑️ Xóa</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary">⬅️ Quay Lại Dashboard</a>
    </div>

    <!-- Create/Edit Modal -->
    <div id="productModal" class="modal" style="display: ${editMode ? 'block' : 'none'};">
        <div class="modal-content">
            <h2>${editMode ? '✏️ Sửa Sản Phẩm' : '➕ Thêm Sản Phẩm Mới'}</h2>
            <form action="${pageContext.request.contextPath}/admin/products" method="post">
                <input type="hidden" name="action" value="${editMode ? 'update' : 'create'}">
                <c:if test="${editMode}">
                    <input type="hidden" name="productId" value="${product.productId}">
                </c:if>
                
                <div class="form-group">
                    <label>Mã Sản Phẩm *</label>
                    <input type="text" name="productCode" value="${product.productCode}" required>
                </div>
                <div class="form-group">
                    <label>Tên Sản Phẩm *</label>
                    <input type="text" name="name" value="${product.name}" required>
                </div>
                <div class="form-group">
                    <label>Danh Mục</label>
                    <input type="text" name="category" value="${product.category}" 
                           placeholder="VD: Laptop, Smartphone, Tablet...">
                </div>
                <div class="form-group">
                    <label>Thương Hiệu</label>
                    <input type="text" name="brand" value="${product.brand}" 
                           placeholder="VD: Apple, Samsung, Dell...">
                </div>
                <div class="form-group">
                    <label>Model</label>
                    <input type="text" name="model" value="${product.model}">
                </div>
                <div class="form-group">
                    <label>Mô Tả</label>
                    <textarea name="description">${product.description}</textarea>
                </div>
                <div class="form-group">
                    <label>Thời Gian Bảo Hành (tháng)</label>
                    <input type="number" name="warrantyMonths" value="${product.warrantyMonths != null ? product.warrantyMonths : 12}" min="0">
                </div>
                <button type="submit" class="btn btn-primary">${editMode ? 'Cập Nhật' : 'Tạo'}</button>
                <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/admin/products?action=list'">❌ Hủy</button>
            </form>
        </div>
    </div>

    <script>
        function showCreateModal() {
            document.getElementById('productModal').style.display = 'block';
        }
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                window.location.href = '${pageContext.request.contextPath}/admin/products?action=list';
            }
        }
    </script>
</body>
</html>
