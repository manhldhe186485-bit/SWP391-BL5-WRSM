package com.warranty.servlet;

import com.warranty.dao.UserDAO;
import com.warranty.model.RepairTicket;
import com.warranty.model.User;
import com.warranty.service.RepairTicketService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for Tech Manager to assign tickets to technicians
 */
@WebServlet("/tech-manager/assign-ticket")
public class AssignTicketServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("TECH_MANAGER") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ========== LẤY DANH SÁCH ĐƠN CHỜ PHÂN CÔNG ==========
        List<RepairTicket> pendingTickets = repairTicketService.getTicketsByStatus(
            RepairTicket.TicketStatus.PENDING
        );

        // ========== LẤY DANH SÁCH KỸ THUẬT VIÊN ==========
        List<User> technicians = userDAO.getUsersByRole(User.UserRole.TECHNICIAN);

        // Set attributes
        request.setAttribute("pendingTickets", pendingTickets);
        request.setAttribute("technicians", technicians);

        // Forward to assign page
        request.getRequestDispatcher("/views/tech-manager/assign-ticket.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("TECH_MANAGER") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get form parameters
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            int technicianId = Integer.parseInt(request.getParameter("technicianId"));
            String priority = request.getParameter("priority");
            String notes = request.getParameter("notes");

            // ========== GỌI SERVICE ĐỂ PHÂN CÔNG ==========
            boolean success = repairTicketService.assignTicket(ticketId, technicianId);

            if (success) {
                // TODO: Send notification to technician
                // TODO: Create assignment log
                
                request.getSession().setAttribute("successMessage", 
                    "Phân công thành công! Đơn đã được giao cho kỹ thuật viên.");
                response.sendRedirect(request.getContextPath() + "/tech-manager/assign-ticket");
            } else {
                throw new Exception("Không thể phân công đơn!");
            }

        } catch (IllegalStateException e) {
            // Business rule violation (từ Service)
            request.setAttribute("error", "Lỗi nghiệp vụ: " + e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
