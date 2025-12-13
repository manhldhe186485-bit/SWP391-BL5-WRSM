package com.warranty.servlet;

import com.warranty.dao.ProductSerialDAO;
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
import java.time.temporal.ChronoUnit;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * Servlet for receiving warranty requests from customers
 * Tech Manager/Reception staff use this
 */
@WebServlet("/tech-manager/receive-product")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB for photos
public class ReceiveProductServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();
    private ProductSerialDAO productSerialDAO = new ProductSerialDAO();

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
            String issueDescription = request.getParameter("issueDescription");
            Part photoPart = request.getPart("photo");
            
            // Validate input
            if (serialNumber == null || serialNumber.trim().isEmpty()) {
                throw new IllegalArgumentException("Số serial không được để trống!");
            }

            // ========== BƯỚC 2: KIỂM TRA SERIAL & THỜI HẠN BẢO HÀNH ==========
            ProductSerial productSerial = productSerialDAO.getBySerialNumber(serialNumber);
            
            if (productSerial == null) {
                throw new IllegalArgumentException("Không tìm thấy sản phẩm với số serial: " + serialNumber);
            }

            // Kiểm tra thời hạn bảo hành
            Date purchaseDate = productSerial.getPurchaseDate();
            Date today = new Date(System.currentTimeMillis());
            long monthsSincePurchase = ChronoUnit.MONTHS.between(purchaseDate.toLocalDate(), today.toLocalDate());
            int warrantyMonths = productSerial.getWarrantyMonths();
            
            boolean isUnderWarranty = monthsSincePurchase < warrantyMonths;
            String warrantyStatus = isUnderWarranty ? 
                "Còn bảo hành (" + (warrantyMonths - monthsSincePurchase) + " tháng)" :
                "Hết bảo hành (đã " + (monthsSincePurchase - warrantyMonths) + " tháng)";

            // ========== BƯỚC 3: TẠO PHIẾU TIẾP NHẬN (RMA) ==========
            RepairTicket ticket = new RepairTicket();
            ticket.setSerialId(productSerial.getSerialId());
            ticket.setCustomerId(productSerial.getCustomerId());
            ticket.setIssueDescription(issueDescription);
            ticket.setReceivedBy(managerId);
            ticket.setReceivedDate(java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            ticket.setStatus(RepairTicket.TicketStatus.PENDING);
            ticket.setIsUnderWarranty(isUnderWarranty);
            
            // Generate ticket code
            String ticketCode = generateTicketCode();
            ticket.setTicketCode(ticketCode);

            // ========== BƯỚC 4: LƯU ẢNH (NẾU CÓ) ==========
            if (photoPart != null && photoPart.getSize() > 0) {
                String photoPath = savePhoto(photoPart, ticketCode);
                // TODO: Save photo path to ticket
            }

            // ========== BƯỚC 5: LƯU VÀO DATABASE ==========
            boolean success = repairTicketService.createRepairTicket(ticket);

            if (success) {
                // Set success message
                request.getSession().setAttribute("successMessage", 
                    "Tiếp nhận thành công! Mã phiếu: " + ticketCode + 
                    "\nTrạng thái BH: " + warrantyStatus);
                
                // Store ticket info for assignment
                request.getSession().setAttribute("newTicketId", ticket.getTicketId());
                
                // Redirect to assign page
                response.sendRedirect(request.getContextPath() + "/tech-manager/assign-ticket");
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
