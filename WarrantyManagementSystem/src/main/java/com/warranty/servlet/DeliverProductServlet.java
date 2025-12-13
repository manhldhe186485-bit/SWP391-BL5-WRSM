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
 * Servlet for delivering repaired product to customer
 * Reception/Technician uses this
 */
@WebServlet("/reception/deliver-product")
public class DeliverProductServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization (Any staff can deliver)
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || role.equals("CUSTOMER")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get completed tickets ready for delivery
        // TODO: Add getReadyForDelivery() method to service
        
        // Forward to delivery page
        request.getRequestDispatcher("/views/reception/deliver-product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        Integer staffId = (Integer) request.getSession().getAttribute("userId");
        
        if (role == null || role.equals("CUSTOMER")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // ========== BƯỚC 1: LẤY THÔNG TIN ==========
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String customerSignature = request.getParameter("customerSignature");
            String deliveryNotes = request.getParameter("deliveryNotes");
            boolean customerAccepted = "true".equals(request.getParameter("customerAccepted"));

            // ========== BƯỚC 2: KIỂM TRA ĐƠN ==========
            RepairTicket ticket = repairTicketService.getTicketById(ticketId);
            
            if (ticket == null) {
                throw new IllegalArgumentException("Không tìm thấy đơn!");
            }

            // Check if ticket is completed
            if (ticket.getStatus() != RepairTicket.TicketStatus.COMPLETED) {
                throw new IllegalStateException("Đơn chưa hoàn thành!");
            }

            // ========== BƯỚC 3: KIỂM TRA THANH TOÁN ==========
            if (ticket.getTotalCost().compareTo(BigDecimal.ZERO) > 0 && !ticket.isPaid()) {
                throw new IllegalStateException("Khách hàng chưa thanh toán! Vui lòng thu tiền trước.");
            }

            // ========== BƯỚC 4: BÀN GIAO ==========
            if (!customerAccepted) {
                throw new IllegalStateException("Khách hàng chưa xác nhận chấp nhận sản phẩm!");
            }

            // Update ticket to DELIVERED
            boolean success = repairTicketService.deliverTicket(ticketId);

            if (success) {
                // TODO: Save delivery record with signature
                // TODO: Send follow-up email after 3-7 days
                // TODO: Create after-service survey
                
                request.getSession().setAttribute("successMessage", 
                    "Đã bàn giao sản phẩm cho khách hàng! Mã đơn: " + ticket.getTicketCode());
                response.sendRedirect(request.getContextPath() + "/reception/deliver-product");
            } else {
                throw new Exception("Không thể bàn giao sản phẩm!");
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
