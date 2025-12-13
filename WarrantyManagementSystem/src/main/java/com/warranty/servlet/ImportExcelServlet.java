package com.warranty.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import com.warranty.util.DatabaseUtil;

/**
 * Servlet for handling Excel import
 */
@MultipartConfig(maxFileSize = 10485760) // 10MB
public class ImportExcelServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has ADMIN role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Return HTML directly with beautiful CSS
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<!DOCTYPE html>");
        response.getWriter().println("<html><head>");
        response.getWriter().println("<meta charset='UTF-8'>");
        response.getWriter().println("<title>Import Excel - Admin</title>");
        response.getWriter().println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>");
        response.getWriter().println("<link href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css' rel='stylesheet'>");
        response.getWriter().println("<style>");
        response.getWriter().println("body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }");
        response.getWriter().println(".main-card { background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }");
        response.getWriter().println(".header-section { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; padding: 30px; border-radius: 15px 15px 0 0; }");
        response.getWriter().println(".upload-zone { border: 3px dashed #11998e; border-radius: 10px; padding: 40px; text-align: center; margin: 20px 0; transition: all 0.3s; }");
        response.getWriter().println(".upload-zone:hover { border-color: #38ef7d; background: #f8f9ff; }");
        response.getWriter().println(".btn-gradient { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; color: white; padding: 12px 30px; border-radius: 25px; }");
        response.getWriter().println(".btn-gradient:hover { background: linear-gradient(135deg, #764ba2 0%, #667eea 100%); color: white; transform: translateY(-2px); }");
        response.getWriter().println(".info-card { background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%); border: none; border-radius: 10px; }");
        response.getWriter().println("</style>");
        response.getWriter().println("</head>");
        response.getWriter().println("<body>");
        response.getWriter().println("<div class='container py-5'>");
        response.getWriter().println("<div class='row justify-content-center'>");
        response.getWriter().println("<div class='col-lg-8'>");
        response.getWriter().println("<div class='main-card'>");
        response.getWriter().println("<div class='header-section text-center'>");
        response.getWriter().println("<h1><i class='fas fa-file-import me-3'></i>Import Dữ Liệu Excel</h1>");
        response.getWriter().println("<p class='mb-0'>Tải lên file Excel để import dữ liệu khách hàng và sản phẩm</p>");
        response.getWriter().println("</div>");
        response.getWriter().println("<div class='p-4'>");
        
        // Form upload
        response.getWriter().println("<form method='post' enctype='multipart/form-data'>");
        response.getWriter().println("<div class='upload-zone'>");
        response.getWriter().println("<i class='fas fa-cloud-upload-alt fa-3x text-primary mb-3'></i>");
        response.getWriter().println("<h5>Chọn file Excel để tải lên</h5>");
        response.getWriter().println("<p class='text-muted'>Hỗ trợ định dạng .xlsx, .xls (tối đa 10MB)</p>");
        response.getWriter().println("<input type='file' class='form-control w-75 mx-auto' name='excelFile' accept='.xlsx,.xls' required>");
        response.getWriter().println("</div>");
        
        // Select data type
        response.getWriter().println("<div class='mb-4'>");
        response.getWriter().println("<label class='form-label'><strong>Loại dữ liệu import:</strong></label>");
        response.getWriter().println("<div class='row'>");
        response.getWriter().println("<div class='col-md-4'>");
        response.getWriter().println("<div class='form-check'>");
        response.getWriter().println("<input class='form-check-input' type='radio' name='dataType' id='customers' value='customers' checked>");
        response.getWriter().println("<label class='form-check-label' for='customers'>");
        response.getWriter().println("<i class='fas fa-users text-primary me-2'></i>Khách hàng");
        response.getWriter().println("</label></div></div>");
        response.getWriter().println("<div class='col-md-4'>");
        response.getWriter().println("<div class='form-check'>");
        response.getWriter().println("<input class='form-check-input' type='radio' name='dataType' id='products' value='products'>");
        response.getWriter().println("<label class='form-check-label' for='products'>");
        response.getWriter().println("<i class='fas fa-box text-success me-2'></i>Sản phẩm");
        response.getWriter().println("</label></div></div>");
        response.getWriter().println("<div class='col-md-4'>");
        response.getWriter().println("<div class='form-check'>");
        response.getWriter().println("<input class='form-check-input' type='radio' name='dataType' id='employees' value='employees'>");
        response.getWriter().println("<label class='form-check-label' for='employees'>");
        response.getWriter().println("<i class='fas fa-user-tie text-warning me-2'></i>Nhân viên");
        response.getWriter().println("</label></div></div>");
        response.getWriter().println("</div></div>");
        
        response.getWriter().println("<div class='text-center'>");
        response.getWriter().println("<button type='submit' class='btn btn-gradient btn-lg'>");
        response.getWriter().println("<i class='fas fa-upload me-2'></i>Tải lên & Xử lý");
        response.getWriter().println("</button>");
        response.getWriter().println("</div>");
        response.getWriter().println("</form>");
        
        // Instructions
        response.getWriter().println("<div class='card info-card mt-4'>");
        response.getWriter().println("<div class='card-body'>");
        response.getWriter().println("<h6><i class='fas fa-info-circle me-2'></i>Hướng dẫn định dạng Excel:</h6>");
        response.getWriter().println("<ul class='mb-0'>");
        response.getWriter().println("<li><strong>Khách hàng:</strong> Họ tên | Email | SĐT | Địa chỉ</li>");
        response.getWriter().println("<li><strong>Sản phẩm:</strong> Mã SP | Tên SP | Giá | Mô tả | Serial Number</li>");
        response.getWriter().println("<li><strong>Nhân viên:</strong> Họ tên | Username | Email | SĐT | Chức vụ</li>");
        response.getWriter().println("</ul>");
        response.getWriter().println("</div></div>");
        
        response.getWriter().println("<div class='text-center mt-4'>");
        response.getWriter().println("<a href='/admin/dashboard' class='btn btn-outline-secondary'>");
        response.getWriter().println("<i class='fas fa-arrow-left me-2'></i>Quay lại Dashboard");
        response.getWriter().println("</a>");
        response.getWriter().println("</div>");
        
        response.getWriter().println("</div></div></div></div></div>");
        response.getWriter().println("</body></html>");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String dataType = request.getParameter("dataType");
        String resultMessage = "";
        String alertType = "success";
        int processedRows = 0;
        
        try {
            // Get uploaded file
            Part filePart = request.getPart("excelFile");
            if (filePart == null || filePart.getSize() == 0) {
                throw new Exception("Không tìm thấy file upload!");
            }
            
            String fileName = getFileName(filePart);
            InputStream inputStream = filePart.getInputStream();
            
            // Read Excel file
            Workbook workbook = null;
            if (fileName.endsWith(".xlsx")) {
                workbook = new XSSFWorkbook(inputStream);
            } else if (fileName.endsWith(".xls")) {
                workbook = new HSSFWorkbook(inputStream);
            } else {
                throw new Exception("File phải có định dạng .xlsx hoặc .xls!");
            }
            
            Sheet sheet = workbook.getSheetAt(0);
            
            // Process based on data type
            if ("customers".equals(dataType)) {
                processedRows = processCustomers(sheet);
                resultMessage = "Import " + processedRows + " khách hàng thành công!";
            } else if ("products".equals(dataType)) {
                processedRows = processProducts(sheet);
                resultMessage = "Import " + processedRows + " sản phẩm thành công!";
            } else if ("employees".equals(dataType)) {
                processedRows = processEmployees(sheet);
                resultMessage = "Import " + processedRows + " nhân viên thành công!";
            }
            
            workbook.close();
            inputStream.close();
            
        } catch (Exception e) {
            alertType = "danger";
            resultMessage = "Lỗi xử lý file: " + e.getMessage();
        }
        
        // Return result HTML
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<!DOCTYPE html>");
        response.getWriter().println("<html><head>");
        response.getWriter().println("<meta charset='UTF-8'>");
        response.getWriter().println("<title>Kết quả Import</title>");
        response.getWriter().println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet'>");
        response.getWriter().println("<link href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css' rel='stylesheet'>");
        response.getWriter().println("<style>");
        response.getWriter().println("body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }");
        response.getWriter().println(".result-card { background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }");
        response.getWriter().println("</style></head>");
        response.getWriter().println("<body>");
        response.getWriter().println("<div class='container py-5'>");
        response.getWriter().println("<div class='row justify-content-center'>");
        response.getWriter().println("<div class='col-lg-6'>");
        response.getWriter().println("<div class='result-card p-5 text-center'>");
        
        if ("success".equals(alertType)) {
            response.getWriter().println("<i class='fas fa-check-circle fa-4x text-success mb-4'></i>");
            response.getWriter().println("<h3 class='text-success'>Thành công!</h3>");
        } else {
            response.getWriter().println("<i class='fas fa-exclamation-triangle fa-4x text-danger mb-4'></i>");
            response.getWriter().println("<h3 class='text-danger'>Có lỗi xảy ra!</h3>");
        }
        
        response.getWriter().println("<p class='lead'>" + resultMessage + "</p>");
        response.getWriter().println("<div class='mt-4'>");
        response.getWriter().println("<a href='/admin/import-excel' class='btn btn-primary me-3'>");
        response.getWriter().println("<i class='fas fa-upload me-2'></i>Import thêm file");
        response.getWriter().println("</a>");
        response.getWriter().println("<a href='/admin/dashboard' class='btn btn-outline-secondary'>");
        response.getWriter().println("<i class='fas fa-home me-2'></i>Dashboard");
        response.getWriter().println("</a>");
        response.getWriter().println("</div>");
        response.getWriter().println("</div></div></div></div></div>");
        response.getWriter().println("</body></html>");
    }
    
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
    
    private int processCustomers(Sheet sheet) throws SQLException {
        int count = 0;
        String sql = "INSERT INTO customers (full_name, email, phone_number, address, created_date) VALUES (?, ?, ?, ?, NOW())";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            // Bỏ qua header row (row 0)
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                try {
                    String fullName = getCellValue(row.getCell(0));
                    String email = getCellValue(row.getCell(1));
                    String phone = getCellValue(row.getCell(2));
                    String address = getCellValue(row.getCell(3));
                    
                    if (fullName != null && !fullName.trim().isEmpty()) {
                        stmt.setString(1, fullName.trim());
                        stmt.setString(2, email != null ? email.trim() : "");
                        stmt.setString(3, phone != null ? phone.trim() : "");
                        stmt.setString(4, address != null ? address.trim() : "");
                        
                        stmt.executeUpdate();
                        count++;
                    }
                } catch (Exception e) {
                    // Skip invalid rows, log error
                    System.err.println("Lỗi xử lý row " + (i+1) + ": " + e.getMessage());
                }
            }
        }
        return count;
    }
    
    private int processProducts(Sheet sheet) throws SQLException {
        int count = 0;
        String productSql = "INSERT INTO products (product_code, product_name, price, description, created_date) VALUES (?, ?, ?, ?, NOW())";
        String serialSql = "INSERT INTO product_serials (product_id, serial_number, status, created_date) VALUES (LAST_INSERT_ID(), ?, 'AVAILABLE', NOW())";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement productStmt = conn.prepareStatement(productSql);
             PreparedStatement serialStmt = conn.prepareStatement(serialSql)) {
            
            // Format: Mã SP | Tên SP | Giá | Mô tả | Serial Number
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                try {
                    String productCode = getCellValue(row.getCell(0));
                    String productName = getCellValue(row.getCell(1));
                    String price = getCellValue(row.getCell(2));
                    String description = getCellValue(row.getCell(3));
                    String serialNumber = getCellValue(row.getCell(4));
                    
                    if (productCode != null && !productCode.trim().isEmpty()) {
                        // Insert product
                        productStmt.setString(1, productCode.trim());
                        productStmt.setString(2, productName != null ? productName.trim() : "");
                        try {
                            productStmt.setBigDecimal(3, new java.math.BigDecimal(price != null ? price.trim() : "0"));
                        } catch (NumberFormatException e) {
                            productStmt.setBigDecimal(3, java.math.BigDecimal.ZERO);
                        }
                        productStmt.setString(4, description != null ? description.trim() : "");
                        
                        productStmt.executeUpdate();
                        
                        // Insert serial number if provided
                        if (serialNumber != null && !serialNumber.trim().isEmpty()) {
                            serialStmt.setString(1, serialNumber.trim());
                            serialStmt.executeUpdate();
                        }
                        
                        count++;
                    }
                } catch (Exception e) {
                    System.err.println("Lỗi xử lý product row " + (i+1) + ": " + e.getMessage());
                }
            }
        }
        return count;
    }
    
    private int processEmployees(Sheet sheet) throws SQLException {
        int count = 0;
        String sql = "INSERT INTO users (username, full_name, email, phone_number, role, password_hash, status, created_date) VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE', NOW())";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            // Format: Họ tên | Username | Email | SĐT | Chức vụ
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                try {
                    String fullName = getCellValue(row.getCell(0));
                    String username = getCellValue(row.getCell(1));
                    String email = getCellValue(row.getCell(2));
                    String phone = getCellValue(row.getCell(3));
                    String role = getCellValue(row.getCell(4));
                    
                    if (username != null && !username.trim().isEmpty()) {
                        stmt.setString(1, username.trim());
                        stmt.setString(2, fullName != null ? fullName.trim() : "");
                        stmt.setString(3, email != null ? email.trim() : "");
                        stmt.setString(4, phone != null ? phone.trim() : "");
                        
                        // Map role string to enum
                        String mappedRole = mapRole(role);
                        stmt.setString(5, mappedRole);
                        
                        // Default password (should be changed on first login)
                        stmt.setString(6, "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFGjO64ofblaQysjbA2Ho9y"); // password: "123456"
                        
                        stmt.executeUpdate();
                        count++;
                    }
                } catch (Exception e) {
                    System.err.println("Lỗi xử lý employee row " + (i+1) + ": " + e.getMessage());
                }
            }
        }
        return count;
    }
    
    private String mapRole(String role) {
        if (role == null) return "TECHNICIAN";
        
        role = role.toUpperCase().trim();
        switch (role) {
            case "ADMIN":
            case "QUẢN TRỊ":
            case "ADMINISTRATOR":
                return "ADMIN";
            case "TECH_MANAGER":
            case "QUẢN LÝ KỸ THUẬT":
            case "MANAGER":
                return "TECH_MANAGER";
            case "WAREHOUSE":
            case "KHO":
            case "WAREHOUSE STAFF":
                return "WAREHOUSE";
            case "TECHNICIAN":
            case "KỸ THUẬT VIÊN":
            case "TECH":
            default:
                return "TECHNICIAN";
        }
    }
    
    private String getCellValue(Cell cell) {
        if (cell == null) return "";
        
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    return cell.getDateCellValue().toString();
                } else {
                    return String.valueOf((long) cell.getNumericCellValue());
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return "";
        }
    }

}
