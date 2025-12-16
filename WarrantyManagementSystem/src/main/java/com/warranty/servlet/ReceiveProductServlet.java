package com.warranty.servlet;

import com.warranty.dao.CustomerDAO;
import com.warranty.dao.ProductSerialDAO;
import com.warranty.model.Customer;
import com.warranty.model.ProductSerial;
import com.warranty.model.RepairTicket;
import com.warranty.service.RepairTicketService;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.temporal.ChronoUnit;
import java.time.LocalDate;

/**
 * Servlet for receiving warranty requests from customers
 * Tech Manager/Reception staff use this
 */
@WebServlet("/tech-manager/receive-product")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB for photos
public class ReceiveProductServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();
    private ProductSerialDAO productSerialDAO = new ProductSerialDAO();
    private CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization (Tech Manager or Admin)
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("TECH_MANAGER") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Forward to receive product page
        request.getRequestDispatcher("/views/tech-manager/receive-product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        Integer managerId = (Integer) request.getSession().getAttribute("userId");
        
        if (role == null || (!role.equals("TECH_MANAGER") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // ========== BƯỚC 1: LẤY THÔNG TIN TỪ FORM ==========
            String serialNumber = request.getParameter("serialNumber");
            String customerName = request.getParameter("customerName");
            String customerPhone = request.getParameter("customerPhone");
            String customerEmail = request.getParameter("customerEmail");
            String issueDescription = request.getParameter("issueDescription");
            String isWalkInParam = request.getParameter("isWalkIn");
            boolean isWalkIn = "true".equals(isWalkInParam);
            Part photoPart = request.getPart("photo");
            
            // Validate input
            if (serialNumber == null || serialNumber.trim().isEmpty()) {
                throw new IllegalArgumentException("Số serial không được để trống!");
            }

            // ========== BƯỚC 2: KIỂM TRA SERIAL & THỜI HẠN BẢO HÀNH ==========
            ProductSerial productSerial = productSerialDAO.getBySerialNumber(serialNumber);
            
            boolean isUnderWarranty = false;
            String warrantyStatus = "";
            int customerId = 0;
            int serialId = 0;
            
            if (productSerial == null || isWalkIn) {
                // ========== KHÔNG TÌM THẤY SERIAL HOẶC WALK-IN → TẠO TICKET SỬA CHỮA ==========
                warrantyStatus = "Sản phẩm không có trong hệ thống - Tạo phiếu sửa chữa trả phí";
                isUnderWarranty = false;
                
                // Validate customer info for walk-in
                if (customerName == null || customerName.trim().isEmpty()) {
                    throw new IllegalArgumentException("Vui lòng nhập tên khách hàng!");
                }
                if (customerPhone == null || customerPhone.trim().isEmpty()) {
                    throw new IllegalArgumentException("Vui lòng nhập số điện thoại khách hàng!");
                }
                
                // Tạo customer mới từ thông tin form
                Customer newCustomer = new Customer();
                newCustomer.setFullName(customerName);
                newCustomer.setPhone(customerPhone);
                newCustomer.setEmail(customerEmail != null ? customerEmail : "");
                newCustomer.setAddress("");
                
                boolean customerCreated = customerDAO.insertCustomer(newCustomer);
                if (customerCreated) {
                    customerId = newCustomer.getCustomerId();
                } else {
                    throw new Exception("Không thể tạo thông tin khách hàng!");
                }
                
                // Tạo product_serial tạm thời
                ProductSerial tempSerial = new ProductSerial();
                tempSerial.setSerialNumber(serialNumber);
                tempSerial.setProductId(1); // Temporary - giả sử product_id=1 tồn tại (sản phẩm "Khác")
                tempSerial.setCustomerId(customerId);
                tempSerial.setPurchaseDate(new Date(System.currentTimeMillis()));
                tempSerial.setWarrantyStartDate(new Date(System.currentTimeMillis()));
                tempSerial.setWarrantyEndDate(new Date(System.currentTimeMillis())); // Hết bảo hành ngay
                tempSerial.setNotes("Walk-in repair - không có trong hệ thống");
                
                boolean serialCreated = productSerialDAO.create(tempSerial);
                if (serialCreated) {
                    serialId = tempSerial.getSerialId();
                    productSerial = tempSerial; // QUAN TRỌNG: Gán lại để tránh null pointer
                } else {
                    throw new Exception("Không thể tạo thông tin serial!");
                }
                
            } else {
                // ========== TÌM THẤY SERIAL → KIỂM TRA BẢO HÀNH ==========
                serialId = productSerial.getSerialId();
                customerId = productSerial.getCustomerId();
                
                // Kiểm tra thời hạn bảo hành dựa trên warranty_end_date
                Date warrantyEndDate = productSerial.getWarrantyEndDate();
                Date today = new Date(System.currentTimeMillis());
                
                isUnderWarranty = warrantyEndDate != null && today.before(warrantyEndDate);
                
                if (isUnderWarranty) {
                    long daysRemaining = ChronoUnit.DAYS.between(today.toLocalDate(), warrantyEndDate.toLocalDate());
                    long monthsRemaining = daysRemaining / 30;
                    warrantyStatus = "Còn bảo hành (còn " + monthsRemaining + " tháng)";
                } else {
                    long daysExpired = ChronoUnit.DAYS.between(warrantyEndDate.toLocalDate(), today.toLocalDate());
                    long monthsExpired = daysExpired / 30;
                    warrantyStatus = "Hết bảo hành (đã " + monthsExpired + " tháng)";
                }
            }

            // ========== BƯỚC 3: TẠO PHIẾU TIẾP NHẬN (RMA) ==========
            RepairTicket ticket = new RepairTicket();
            
            // Generate ticket number
            String ticketNumber = generateTicketCode();
            ticket.setTicketNumber(ticketNumber);
            
            // Set required fields matching database schema
            ticket.setSerialId(serialId);  // Dùng biến đã lưu
            ticket.setCustomerId(customerId);  // Dùng biến đã lưu
            ticket.setIntakeTechnicianId(managerId); // intake_technician_id in DB
            ticket.setIssueDescription(issueDescription);
            
            // Set ticket type based on warranty status
            if (isUnderWarranty) {
                ticket.setTicketType(RepairTicket.TicketType.WARRANTY);
            } else {
                ticket.setTicketType(RepairTicket.TicketType.PAID_REPAIR);
            }
            
            // Set status to PENDING_ASSIGNMENT (default in constructor)
            ticket.setStatus(RepairTicket.TicketStatus.PENDING_ASSIGNMENT);
            
            // Priority from form or default MEDIUM
            String priorityParam = request.getParameter("priority");
            if (priorityParam != null && !priorityParam.isEmpty()) {
                ticket.setPriority(RepairTicket.Priority.valueOf(priorityParam));
            }
            
            // Received date is auto-set by database DEFAULT CURRENT_TIMESTAMP
            ticket.setReceivedDate(new Timestamp(System.currentTimeMillis()));

            // ========== BƯỚC 4: LƯU ẢNH (NẾU CÓ) ==========
            if (photoPart != null && photoPart.getSize() > 0) {
                String photoPath = savePhoto(photoPart, ticketNumber);
                // TODO: Save photo path to ticket
            }

            // ========== BƯỚC 5: LƯU VÀO DATABASE ==========
            boolean success = repairTicketService.createRepairTicket(ticket);

            if (success) {
                // Set success message
                request.getSession().setAttribute("message", 
                    "Tiếp nhận thành công! Mã phiếu: " + ticketNumber + 
                    " - " + warrantyStatus);
                
                // Redirect to dashboard or assignment
                response.sendRedirect(request.getContextPath() + "/tech-manager/dashboard");
            } else {
                throw new Exception("Không thể tạo phiếu tiếp nhận!");
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/views/tech-manager/receive-product.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/tech-manager/receive-product.jsp").forward(request, response);
        }
    }

    /**
     * Generate unique ticket code
     * Format: WR-YYYY-NNNN
     */
    private String generateTicketCode() {
        int year = java.time.Year.now().getValue();
        // TODO: Get count from database
        int count = (int)(Math.random() * 9999) + 1;
        return String.format("WR-%d-%04d", year, count);
    }

    /**
     * Save uploaded photo
     */
    private String savePhoto(Part photoPart, String ticketCode) throws IOException {
        // TODO: Implement photo saving
        // Save to: /upload/tickets/{ticketCode}/photo_{timestamp}.jpg
        String fileName = ticketCode + "_" + System.currentTimeMillis() + ".jpg";
        String uploadPath = "/upload/tickets/" + ticketCode + "/";
        
        // Create directory if not exists
        // Save file
        
        return uploadPath + fileName;
    }
}
