# HƯỚNG DẪN PHÁT TRIỂN TIẾP

## Các file đã được tạo

### ✅ Hoàn thành:
1. **Cấu trúc thư mục** - Đã tạo đầy đủ
2. **Database Schema** - `database/schema.sql`
3. **Configuration Files**:
   - `pom.xml` - Maven dependencies
   - `web.xml` - Servlet configuration
   - `database.properties` - DB config
   - `mail.properties` - Email config

4. **Model Classes** (8 files):
   - User.java
   - Customer.java
   - Product.java
   - ProductSerial.java
   - RepairTicket.java
   - InventoryItem.java
   - PartsRequest.java
   - PartsRequestItem.java
   - RepairProgressLog.java
   - Notification.java

5. **Utility Classes** (5 files):
   - DatabaseUtil.java
   - PasswordUtil.java
   - ExcelUtil.java
   - NumberGenerator.java
   - DateUtil.java

6. **DAO Classes** (2 files cơ bản):
   - UserDAO.java
   - RepairTicketDAO.java

7. **Filters**:
   - AuthenticationFilter.java
   - CharacterEncodingFilter.java

8. **Servlets**:
   - LoginServlet.java
   - LogoutServlet.java

9. **JSP Views**:
   - index.jsp
   - login.jsp

## Các file CẦN TẠO THÊM để hoàn thiện hệ thống

### 1. DAO Classes (Còn thiếu)

```java
// c:\Web\WarrantyManagementSystem\src\main\java\com\warranty\dao\

CustomerDAO.java           // CRUD cho Customer
ProductDAO.java            // CRUD cho Product
ProductSerialDAO.java      // CRUD cho ProductSerial
InventoryItemDAO.java      // CRUD cho InventoryItem
PartsRequestDAO.java       // CRUD cho PartsRequest
RepairProgressLogDAO.java  // CRUD cho RepairProgressLog
NotificationDAO.java       // CRUD cho Notification
```

### 2. Servlet Controllers (Còn thiếu)

```java
// c:\Web\WarrantyManagementSystem\src\main\java\com\warranty\servlet\

RegisterServlet.java               // Đăng ký customer
ImportExcelServlet.java            // Import Excel data
ProductCustomerListServlet.java    // Danh sách sản phẩm
CreateIntakeTicketServlet.java     // Tạo phiếu tiếp nhận
TechnicianDashboardServlet.java    // Dashboard technician
TechManagerDashboardServlet.java   // Dashboard tech manager
AssignTicketServlet.java           // Phân công ticket
WarehouseServlet.java              // Quản lý kho
CustomerPortalServlet.java         // Portal khách hàng
UpdateProgressServlet.java         // Cập nhật tiến trình
CreatePartsRequestServlet.java     // Tạo yêu cầu linh kiện
ProcessPartsRequestServlet.java    // Xử lý yêu cầu linh kiện
```

### 3. JSP Views (Còn thiếu)

```
c:\Web\WarrantyManagementSystem\src\main\webapp\views\

admin/
  - dashboard.jsp              // Dashboard admin
  - import-excel.jsp           // Form import Excel
  - product-list.jsp           // Danh sách sản phẩm
  - user-management.jsp        // Quản lý user

tech-manager/
  - dashboard.jsp              // Dashboard quản lý kỹ thuật
  - assign-ticket.jsp          // Form phân công
  - ticket-list.jsp            // Danh sách tickets

technician/
  - dashboard.jsp              // Dashboard kỹ thuật viên
  - create-ticket.jsp          // Tạo phiếu tiếp nhận
  - ticket-detail.jsp          // Chi tiết ticket
  - update-progress.jsp        // Cập nhật tiến trình
  - create-parts-request.jsp   // Yêu cầu linh kiện

warehouse/
  - dashboard.jsp              // Dashboard kho
  - inventory-list.jsp         // Danh sách tồn kho
  - parts-request-list.jsp     // Danh sách yêu cầu
  - process-request.jsp        // Xử lý yêu cầu

customer/
  - portal.jsp                 // Portal khách hàng
  - track-ticket.jsp           // Tra cứu đơn hàng
  - ticket-history.jsp         // Lịch sử

common/
  - header.jsp                 // Header chung
  - footer.jsp                 // Footer chung
  - sidebar.jsp                // Sidebar navigation

error/
  - 404.jsp                    // Page not found
  - 500.jsp                    // Server error
```

### 4. CSS & JavaScript

```
c:\Web\WarrantyManagementSystem\src\main\webapp\css\

style.css                    // Style chung
admin.css                    // Style cho admin
technician.css              // Style cho technician
customer.css                // Style cho customer
```

```
c:\Web\WarrantyManagementSystem\src\main\webapp\js\

main.js                     // JS chung
dashboard.js                // Dashboard functionality
form-validation.js          // Validation
ajax-utils.js               // AJAX calls
```

## MẪU CODE tham khảo cho các file còn thiếu

### 1. Mẫu DAO Class

```java
package com.warranty.dao;

import com.warranty.model.Customer;
import com.warranty.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {
    
    public boolean createCustomer(Customer customer) {
        String sql = "INSERT INTO customers (customer_code, full_name, email, phone, address) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, customer.getCustomerCode());
            stmt.setString(2, customer.getFullName());
            stmt.setString(3, customer.getEmail());
            stmt.setString(4, customer.getPhone());
            stmt.setString(5, customer.getAddress());
            
            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        customer.setCustomerId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public Customer getCustomerById(int customerId) {
        // Implement SELECT by ID
        return null;
    }
    
    public List<Customer> getAllCustomers() {
        // Implement SELECT all
        return new ArrayList<>();
    }
    
    // ... other methods
}
```

### 2. Mẫu Servlet

```java
package com.warranty.servlet;

import com.warranty.dao.CustomerDAO;
import com.warranty.model.Customer;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class RegisterServlet extends HttpServlet {
    
    private CustomerDAO customerDAO = new CustomerDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        
        // Validation
        if (fullName == null || email == null || phone == null) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        // Create customer
        Customer customer = new Customer(fullName, phone, email, address);
        boolean success = customerDAO.createCustomer(customer);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?registered=true");
        } else {
            request.setAttribute("error", "Đăng ký thất bại");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
```

### 3. Mẫu JSP Dashboard

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Technician</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="/views/common/header.jsp" %>
    
    <div class="container">
        <h1>Dashboard Kỹ thuật viên</h1>
        
        <div class="stats">
            <div class="stat-card">
                <h3>${totalTickets}</h3>
                <p>Tổng phiếu</p>
            </div>
            <div class="stat-card">
                <h3>${inProgressTickets}</h3>
                <p>Đang xử lý</p>
            </div>
            <div class="stat-card">
                <h3>${completedTickets}</h3>
                <p>Hoàn thành</p>
            </div>
        </div>
        
        <div class="ticket-list">
            <h2>Phiếu của tôi</h2>
            <table>
                <thead>
                    <tr>
                        <th>Mã phiếu</th>
                        <th>Khách hàng</th>
                        <th>Sản phẩm</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="ticket" items="${tickets}">
                        <tr>
                            <td>${ticket.ticketNumber}</td>
                            <td>${ticket.customer.fullName}</td>
                            <td>${ticket.productSerial.product.productName}</td>
                            <td>${ticket.status}</td>
                            <td>
                                <a href="ticket-detail?id=${ticket.ticketId}">Xem</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
    <%@ include file="/views/common/footer.jsp" %>
</body>
</html>
```

## BƯỚC TIẾP THEO để hoàn thiện

### Bước 1: Tạo các DAO còn thiếu
- Copy mẫu DAO và customize cho từng entity
- Test kết nối database

### Bước 2: Tạo các Servlet
- Implement business logic cho từng chức năng
- Kết nối với DAO layer
- Handle request/response

### Bước 3: Tạo JSP Views
- Tạo giao diện cho từng role
- Sử dụng JSTL và EL
- Tích hợp CSS/JS

### Bước 4: Testing
- Test từng chức năng
- Test integration
- Fix bugs

### Bước 5: Deployment
- Build WAR file
- Deploy lên Tomcat
- Test production

## PRIORITY các chức năng

### HIGH Priority:
1. ✅ Login/Logout
2. ⬜ Technician create intake ticket
3. ⬜ Tech Manager assign ticket
4. ⬜ Technician update progress
5. ⬜ Customer track ticket

### MEDIUM Priority:
6. ⬜ Admin import Excel
7. ⬜ Parts request workflow
8. ⬜ Warehouse inventory management
9. ⬜ Payment processing

### LOW Priority:
10. ⬜ Notifications
11. ⬜ Reports
12. ⬜ User management
13. ⬜ Settings

## GỢI Ý phát triển

1. **Bắt đầu từ workflow chính**: Technician → Tech Manager → Customer
2. **Tạo từng màn hình một**: Hoàn thiện trước khi chuyển sang màn khác
3. **Test ngay**: Mỗi khi hoàn thành một chức năng
4. **Sử dụng mẫu**: Copy code mẫu và customize
5. **Commit thường xuyên**: Để dễ rollback khi cần

## Liên hệ hỗ trợ

Nếu cần hỗ trợ thêm về bất kỳ phần nào, hãy hỏi cụ thể:
- DAO cho entity nào?
- Servlet cho chức năng gì?
- JSP cho màn hình nào?

Good luck! 🚀
