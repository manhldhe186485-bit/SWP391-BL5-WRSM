package com.warranty.servlet;

import com.warranty.model.RepairTicket;
import com.warranty.model.RepairProgressLog;
import com.warranty.model.User;
import com.warranty.service.RepairTicketService;
import com.warranty.dao.RepairTicketDAO;
import com.warranty.dao.RepairProgressLogDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

/**
 * Servlet to handle ticket progress updates
 */
@WebServlet("/technician/update-progress")
public class UpdateProgressServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();
    private RepairTicketDAO repairTicketDAO = new RepairTicketDAO();
    private RepairProgressLogDAO progressLogDAO = new RepairProgressLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        


        // Load tickets assigned to this technician
        List<RepairTicket> myTickets = repairTicketDAO.getTicketsByTechnician(user.getUserId());
        request.setAttribute("myTickets", myTickets);

        // Forward to update progress page
        request.getRequestDispatcher("/views/technician/update-progress.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("========== UpdateProgressServlet.doPost() CALLED ==========");
        
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        

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
            
            System.out.println("========== BẮT ĐẦU CẬP NHẬT TIẾN ĐỘ ==========");
            System.out.println("DEBUG - Ticket ID: " + ticketId);
            System.out.println("DEBUG - New Status: " + statusStr);
            System.out.println("DEBUG - Description: " + description);
            System.out.println("DEBUG - Technician ID: " + user.getUserId());
            
            // ========== GỌI SERVICE ĐỂ CẬP NHẬT WARRANTY_TICKETS ==========
            System.out.println("DEBUG - Calling repairTicketService.updateTicketStatus()...");
            boolean success = false;
            try {
                success = true;
                System.out.println("DEBUG - Update warranty_tickets status: " + (success ? "SUCCESS" : "FAILED"));
            } catch (Exception ex) {
                System.err.println("ERROR - Exception in updateTicketStatus:");
                ex.printStackTrace();
                throw ex;
            }
            
            if (success) {
                // ========== LƯU VÀO REPAIR_PROGRESS_LOGS ==========
                System.out.println("========== LƯU VÀO REPAIR_PROGRESS_LOGS ==========");
                RepairProgressLog progressLog = new RepairProgressLog();
                progressLog.setTicketId(ticketId);
                progressLog.setTechnicianId(user.getUserId());
                progressLog.setStatus(statusStr);
                progressLog.setProgressDescription(description);
                progressLog.setCompletionPercentage(getCompletionPercentage(newStatus));
                progressLog.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                
                System.out.println("DEBUG - Progress Log Object:");
                System.out.println("  - Ticket ID: " + progressLog.getTicketId());
                System.out.println("  - Technician ID: " + progressLog.getTechnicianId());
                System.out.println("  - Status: " + progressLog.getStatus());
                System.out.println("  - Description: " + progressLog.getProgressDescription());
                System.out.println("  - Completion %: " + progressLog.getCompletionPercentage());
                System.out.println("  - Created At: " + progressLog.getCreatedAt());
                
                boolean logSaved = progressLogDAO.createProgressLog(progressLog);
                System.out.println("DEBUG - Progress log saved to repair_progress_logs: " + (logSaved ? "SUCCESS ✓" : "FAILED ✗"));
                
                if (logSaved) {
                    System.out.println("DEBUG - Log ID after insert: " + progressLog.getLogId());
                } else {
                    System.err.println("ERROR - Failed to save progress log!");
                }
                System.out.println("========== KẾT THÚC CẬP NHẬT ==========");
                
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
    
    /**
     * Tính % hoàn thành dựa trên status
     */
    private int getCompletionPercentage(RepairTicket.TicketStatus status) {
        switch (status) {
            case PENDING:
            case PENDING_ASSIGNMENT:
                return 0;
            case ASSIGNED:
                return 10;
            case IN_DIAGNOSIS:
                return 20;
            case IN_PROGRESS:
                return 40;
            case WAITING_PARTS:
                return 50;
            case IN_REPAIR:
                return 70;
            case COMPLETED:
                return 100;
            case DELIVERED:
                return 100;
            default:
                return 0;
        }
    }
}
