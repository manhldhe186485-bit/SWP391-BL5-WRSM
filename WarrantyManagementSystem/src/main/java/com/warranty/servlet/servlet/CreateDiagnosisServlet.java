package com.warranty.servlet;

import com.warranty.model.RepairTicket;
import com.warranty.service.RepairTicketService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;

/**
 * Servlet for creating diagnosis report and cost estimate
 * Technician uses this after checking the device
 */
@WebServlet("/technician/create-diagnosis")
public class CreateDiagnosisServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get ticket ID from parameter
        String ticketIdParam = request.getParameter("ticketId");
        if (ticketIdParam != null) {
            try {
                int ticketId = Integer.parseInt(ticketIdParam);
                RepairTicket ticket = repairTicketService.getTicketById(ticketId);
                request.setAttribute("ticket", ticket);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Mã đơn không hợp lệ!");
            }
        }

        // Forward to diagnosis page
        request.getRequestDispatcher("/views/technician/create-diagnosis.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        Integer technicianId = (Integer) request.getSession().getAttribute("userId");
        
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // ========== BƯỚC 1: LẤY THÔNG TIN CHẨN ĐOÁN ==========
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String diagnosisResult = request.getParameter("diagnosisResult");
            String repairMethod = request.getParameter("repairMethod"); // Sửa chữa / Thay linh kiện / Nâng cấp FW
            String partsNeeded = request.getParameter("partsNeeded");
            
            // Cost estimate
            double partsCost = Double.parseDouble(request.getParameter("partsCost"));
            double laborCost = Double.parseDouble(request.getParameter("laborCost"));
            double totalCost = partsCost + laborCost;
            
            String estimatedTime = request.getParameter("estimatedTime");
            boolean isUnderWarranty = "true".equals(request.getParameter("isUnderWarranty"));

            // ========== BƯỚC 2: CẬP NHẬT TICKET ==========
            RepairTicket ticket = repairTicketService.getTicketById(ticketId);
            
            if (ticket == null) {
                throw new IllegalArgumentException("Không tìm thấy đơn!");
            }

            // Check ownership
            if (ticket.getTechnicianId() != technicianId) {
                throw new IllegalStateException("Bạn không có quyền xử lý đơn này!");
            }

            // Update ticket info
            // TODO: Save diagnosis details to database
            ticket.setTotalCost(isUnderWarranty ? BigDecimal.ZERO : BigDecimal.valueOf(totalCost));
            
            // ========== BƯỚC 3: ĐỔI TRẠNG THÁI ==========
            // Nếu thuộc BH → IN_PROGRESS (sửa luôn)
            // Nếu không thuộc BH → WAITING_APPROVAL (chờ khách duyệt giá)
            RepairTicket.TicketStatus newStatus = isUnderWarranty ? 
                RepairTicket.TicketStatus.IN_PROGRESS :
                RepairTicket.TicketStatus.WAITING_APPROVAL;

            String notes = "Chẩn đoán: " + diagnosisResult + 
                          "\nPhương án: " + repairMethod +
                          (isUnderWarranty ? "\n✓ Miễn phí (còn bảo hành)" : 
                           "\n$ Chi phí: " + String.format("%,.0f VNĐ", totalCost));

            boolean success = repairTicketService.updateTicketStatus(ticketId, newStatus, notes);

            if (success) {
                // TODO: Create diagnosis record
                // TODO: Send notification to customer (if waiting approval)
                
                String message = isUnderWarranty ?
                    "Chẩn đoán hoàn tất! Bắt đầu sửa chữa (miễn phí)." :
                    "Chẩn đoán hoàn tất! Đã gửi báo giá cho khách hàng (Tổng: " + 
                    String.format("%,.0f VNĐ", totalCost) + "). Chờ duyệt...";
                
                request.getSession().setAttribute("successMessage", message);
                response.sendRedirect(request.getContextPath() + "/technician/my-tickets");
            } else {
                throw new Exception("Không thể lưu chẩn đoán!");
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
