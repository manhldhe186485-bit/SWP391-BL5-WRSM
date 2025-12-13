<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Kho Linh Kiện</title>
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
        .alert-warning { background: #fff3cd; color: #856404; }
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
        input, textarea, select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        textarea { min-height: 60px; resize: vertical; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; }
        .modal-content { background: white; margin: 30px auto; padding: 30px; max-width: 700px; border-radius: 10px; max-height: 85vh; overflow-y: auto; }
        .stock-low { color: #dc3545; font-weight: bold; }
        .stock-ok { color: #28a745; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📦 Quản Lý Kho Linh Kiện</h1>
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
                <h2>📋 Danh Sách Linh Kiện (${items.size()})</h2>
                <div>
                    <button class="btn btn-success" onclick="showImportModal()">📥 Nhập Linh Kiện</button>
                    <button class="btn btn-primary" onclick="showCreateModal()">➕ Thêm Linh Kiện Mới</button>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Mã LK</th>
                        <th>Tên Linh Kiện</th>
                        <th>Danh Mục</th>
                        <th>Nhà Cung Cấp</th>
                        <th>Tồn Kho</th>
                        <th>Tối Thiểu</th>
                        <th>Đơn Giá</th>
                        <th>Vị Trí</th>
                        <th>Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty items}">
                        <tr><td colspan="9" style="text-align: center; color: #999; padding: 40px;">Chưa có linh kiện nào trong kho</td></tr>
                    </c:if>
                    <c:forEach items="${items}" var="item">
                        <tr>
                            <td><strong>${item.partNumber}</strong></td>
                            <td>${item.partName}</td>
                            <td>${item.category}</td>
                            <td>${item.supplier}</td>
                            <td class="${item.quantityAvailable <= item.minQuantity ? 'stock-low' : 'stock-ok'}">
                                ${item.quantityAvailable}
                                ${item.quantityAvailable <= item.minQuantity ? '⚠️' : ''}
                            </td>
                            <td>${item.minQuantity}</td>
                            <td>${item.unitPrice} VNĐ</td>
                            <td>${item.location}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/warehouse/inventory?action=edit&itemId=${item.itemId}" 
                                   class="btn btn-warning">✏️</a>
                                <button class="btn btn-success" onclick="showImportModalForItem(${item.itemId}, '${item.partName}')">📥</button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <a href="${pageContext.request.contextPath}/warehouse/dashboard" class="btn btn-secondary">⬅️ Quay Lại Dashboard</a>
    </div>

    <!-- Create/Edit Modal -->
    <div id="itemModal" class="modal" style="display: ${editMode ? 'block' : 'none'};">
        <div class="modal-content">
            <h2>${editMode ? '✏️ Sửa Linh Kiện' : '➕ Thêm Linh Kiện Mới'}</h2>
            <form action="${pageContext.request.contextPath}/warehouse/inventory" method="post">
                <input type="hidden" name="action" value="${editMode ? 'update' : 'create'}">
                <c:if test="${editMode}">
                    <input type="hidden" name="itemId" value="${item.itemId}">
                </c:if>
                
                <div class="form-group">
                    <label>Mã Linh Kiện *</label>
                    <input type="text" name="partNumber" value="${item.partNumber}" required>
                </div>
                <div class="form-group">
                    <label>Tên Linh Kiện *</label>
                    <input type="text" name="partName" value="${item.partName}" required>
                </div>
                <div class="form-group">
                    <label>Danh Mục</label>
                    <input type="text" name="category" value="${item.category}" 
                           placeholder="VD: Màn hình, Pin, Bo mạch...">
                </div>
                <div class="form-group">
                    <label>Nhà Cung Cấp</label>
                    <input type="text" name="supplier" value="${item.supplier}">
                </div>
                <div class="form-group">
                    <label>Mô Tả</label>
                    <textarea name="description">${item.description}</textarea>
                </div>
                <div class="form-group">
                    <label>Số Lượng Tồn Kho *</label>
                    <input type="number" name="quantity" value="${item.quantityAvailable != null ? item.quantityAvailable : 0}" min="0" required>
                </div>
                <div class="form-group">
                    <label>Số Lượng Tối Thiểu</label>
                    <input type="number" name="minQuantity" value="${item.minQuantity != null ? item.minQuantity : 5}" min="0">
                </div>
                <div class="form-group">
                    <label>Đơn Giá (VNĐ)</label>
                    <input type="number" name="unitPrice" value="${item.unitPrice}" min="0" step="1000">
                </div>
                <div class="form-group">
                    <label>Vị Trí Lưu Kho</label>
                    <input type="text" name="location" value="${item.location}" 
                           placeholder="VD: Kệ A1, Ngăn B2...">
                </div>
                <button type="submit" class="btn btn-primary">✅ ${editMode ? 'Cập Nhật' : 'Tạo'}</button>
                <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/warehouse/inventory?action=list'">❌ Hủy</button>
            </form>
        </div>
    </div>

    <!-- Import Modal -->
    <div id="importModal" class="modal">
        <div class="modal-content">
            <h2>📥 Nhập Linh Kiện Về Kho</h2>
            <form action="${pageContext.request.contextPath}/warehouse/inventory?action=import" method="post">
                <input type="hidden" name="itemId" id="importItemId">
                
                <div class="form-group">
                    <label>Linh Kiện</label>
                    <div id="importItemName" style="font-weight: bold; padding: 10px; background: #f8f9fa; border-radius: 5px;"></div>
                </div>
                <div class="form-group">
                    <label>Số Lượng Nhập *</label>
                    <input type="number" name="quantity" min="1" required placeholder="Nhập số lượng">
                </div>
                <button type="submit" class="btn btn-success">✅ Xác Nhận Nhập</button>
                <button type="button" class="btn btn-secondary" onclick="hideModal('importModal')">❌ Hủy</button>
            </form>
        </div>
    </div>

    <script>
        function showCreateModal() {
            document.getElementById('itemModal').style.display = 'block';
        }
        function showImportModal() {
            alert('Vui lòng chọn linh kiện cần nhập từ danh sách');
        }
        function showImportModalForItem(itemId, itemName) {
            document.getElementById('importItemId').value = itemId;
            document.getElementById('importItemName').textContent = itemName;
            document.getElementById('importModal').style.display = 'block';
        }
        function hideModal(id) {
            document.getElementById(id).style.display = 'none';
        }
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                window.location.href = '${pageContext.request.contextPath}/warehouse/inventory?action=list';
            }
        }
    </script>
</body>
</html>
