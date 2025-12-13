package com.warranty.servlet;

import com.warranty.model.RepairTicket;
import com.warranty.service.RepairTicketService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet to handle ticket progress updates
 */
@WebServlet("/technician/update-progress")
public class UpdateProgressServlet extends HttpServlet {

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

        // Forward to update progress page
        request.getRequestDispatcher("/views/technician/update-progress.jsp").forward(request, response);
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
            // Get form parameters
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String statusStr = request.getParameter("status");
            String description = request.getParameter("description");
            String customerNote = request.getParameter("customerNote");
            
            // Validate
            if (statusStr == null || statusStr.isEmpty()) {
                throw new IllegalArgumentException("Trạng thái không được để trống");
            }
            
            // Parse status
            RepairTicket.TicketStatus newStatus = RepairTicket.TicketStatus.valueOf(statusStr);
            
            // ========== GỌI SERVICE ĐỂ CẬP NHẬT ==========
            boolean success = repairTicketService.updateTicketStatus(ticketId, newStatus, description);
            
            if (success) {
                // TODO: Create progress log entry
                // TODO: Send notification to customer if checkbox is checked
                
                request.getSession().setAttribute("successMessage", "Cập nhật tiến độ thành công!");
                response.sendRedirect(request.getContextPath() + "/technician/my-tickets");
            } else {
                request.setAttribute("error", "Không thể cập nhật tiến độ. Vui lòng thử lại.");
                request.getRequestDispatcher("/views/technician/update-progress.jsp").forward(request, response);
            }
            
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
            request.getRequestDispatcher("/views/technician/update-progress.jsp").forward(request, response);
        } catch (IllegalStateException e) {
            // Business rule violation (e.g., invalid status transition)
            request.setAttribute("error", "Lỗi nghiệp vụ: " + e.getMessage());
            request.getRequestDispatcher("/views/technician/update-progress.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/technician/update-progress.jsp").forward(request, response);
        }
    }
}
