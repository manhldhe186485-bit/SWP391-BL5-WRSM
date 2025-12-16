package com.warranty.servlet;

import com.warranty.model.RepairTicket;
import com.warranty.model.ProductSerial;
import com.warranty.service.RepairTicketService;
import com.warranty.dao.ProductSerialDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.Calendar;

/**
 * Servlet for creating warranty slip after repair completion
 */
@WebServlet("/technician/create-warranty-slip")
public class CreateWarrantySlipServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();
    private ProductSerialDAO productSerialDAO = new ProductSerialDAO();

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
                
                if (ticket != null) {
                    // Load product serial info
                    ProductSerial productSerial = productSerialDAO.getBySerialId(ticket.getSerialId());
                    
                    request.setAttribute("ticket", ticket);
                    request.setAttribute("productSerial", productSerial);
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Không thể tải thông tin ticket: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("/views/technician/create-warranty-slip.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get form parameters
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            int serialId = Integer.parseInt(request.getParameter("serialId"));
            int warrantyMonths = Integer.parseInt(request.getParameter("warrantyMonths"));
            String repairSummary = request.getParameter("repairSummary");
            String replacedParts = request.getParameter("replacedParts");
            String warrantyTerms = request.getParameter("warrantyTerms");

            // Get ticket
            RepairTicket ticket = repairTicketService.getTicketById(ticketId);
            
            if (ticket == null) {
                throw new Exception("Ticket không tồn tại!");
            }

            // Update product serial warranty dates
            ProductSerial productSerial = productSerialDAO.getBySerialId(serialId);
            
            if (productSerial != null) {
                // Set new warranty start date (today)
                Date today = new Date(System.currentTimeMillis());
                productSerial.setWarrantyStartDate(today);
                
                // Calculate warranty end date
                Calendar cal = Calendar.getInstance();
                cal.setTime(today);
                cal.add(Calendar.MONTH, warrantyMonths);
                productSerial.setWarrantyEndDate(new Date(cal.getTimeInMillis()));
                
                // Update notes with repair info
                String notes = "Sửa chữa: " + repairSummary + 
                              "\nThay thế: " + (replacedParts != null ? replacedParts : "Không") +
                              "\nĐiều khoản BH: " + (warrantyTerms != null ? warrantyTerms : "Theo chính sách");
                productSerial.setNotes(notes);
                
                // Update in database
                productSerialDAO.update(productSerial);
            }

            // Update ticket status to COMPLETED
            ticket.setStatus(RepairTicket.TicketStatus.COMPLETED);
            ticket.setNotes("Phiếu bảo hành đã tạo. " + repairSummary);
            repairTicketService.updateTicketStatus(ticket.getTicketId(), 
                                                  RepairTicket.TicketStatus.COMPLETED, 
                                                  repairSummary);

            // Set success message
            request.getSession().setAttribute("successMessage", 
                "Tạo phiếu bảo hành thành công! Bảo hành " + warrantyMonths + " tháng.");
            
            response.sendRedirect(request.getContextPath() + "/technician/my-tickets");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
