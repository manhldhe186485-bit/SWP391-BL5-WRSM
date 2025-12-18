package com.warranty.servlet;

import com.warranty.dao.PartsRequestDAO;
import com.warranty.dao.RepairTicketDAO;
import com.warranty.model.PartsRequest;
import com.warranty.model.PartsRequestItem;
import com.warranty.model.RepairTicket;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet to handle parts requests from technicians
 */
@WebServlet("/technician/request-parts")
public class RequestPartsServlet extends HttpServlet {

    private PartsRequestDAO partsRequestDAO = new PartsRequestDAO();
    private RepairTicketDAO repairTicketDAO = new RepairTicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer technicianId = (Integer) request.getSession().getAttribute("userId");
        
        System.out.println("========== RequestPartsServlet.doGet() ==========");
        System.out.println("Technician ID: " + technicianId);
        
        // ========== LẤY DANH SÁCH ĐƠN BẢO HÀNH CỦA TECHNICIAN (CHỈ WAITING_PARTS) ==========
        try {
            List<RepairTicket> allTickets = repairTicketDAO.getTicketsByTechnician(technicianId);
            System.out.println("All Tickets loaded: " + allTickets.size());
            
            // Filter chỉ lấy đơn WAITING_PARTS
            List<RepairTicket> waitingPartsTickets = new ArrayList<>();
            for (RepairTicket ticket : allTickets) {
                if ("WAITING_PARTS".equals(ticket.getStatus())) {
                    waitingPartsTickets.add(ticket);
                }
            }
            
            System.out.println("WAITING_PARTS Tickets: " + waitingPartsTickets.size());
            request.setAttribute("myTickets", waitingPartsTickets);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("myTickets", new ArrayList<>());
        }
        
        // ========== LẤY LỊCH SỬ YÊU CẦU CỦA TECHNICIAN ==========
        try {
            List<PartsRequest> myRequests = partsRequestDAO.getRequestsByTechnician(technicianId);
            System.out.println("My Requests loaded: " + myRequests.size());
            
            // Log chi tiết các request
            for (PartsRequest req : myRequests) {
                System.out.println("  - Request ID: " + req.getRequestId() + 
                                 ", Number: " + req.getRequestNumber() + 
                                 ", Status: " + req.getStatus());
            }
            
            request.setAttribute("myRequests", myRequests);
        } catch (SQLException e) {
            System.err.println("ERROR loading requests: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("myRequests", new ArrayList<>());
        }

        // Forward to request parts page
        request.getRequestDispatcher("/views/technician/request-parts.jsp").forward(request, response);
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
            System.out.println("========== REQUEST PARTS: BẮT ĐẦU ==========");
            
            // ========== BƯỚC 1: LẤY THÔNG TIN TỪ FORM ==========
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String priority = request.getParameter("priority");
            String notes = request.getParameter("notes");

            System.out.println("Ticket ID: " + ticketId);
            System.out.println("Priority: " + priority);
            System.out.println("Notes: " + notes);

            // Get array of parts
            String[] partNames = request.getParameterValues("partName[]");
            String[] partCodes = request.getParameterValues("partCode[]");
            String[] quantities = request.getParameterValues("quantity[]");
            String[] partNotes = request.getParameterValues("partNote[]");

            System.out.println("Part Names array: " + (partNames != null ? partNames.length + " items" : "NULL"));
            System.out.println("Part Codes array: " + (partCodes != null ? partCodes.length + " items" : "NULL"));
            System.out.println("Quantities array: " + (quantities != null ? quantities.length + " items" : "NULL"));

            if (partNames == null || partNames.length == 0) {
                throw new IllegalArgumentException("Phải có ít nhất 1 linh kiện!");
            }

            // ========== BƯỚC 2: TẠO PARTS REQUEST ==========
            PartsRequest partsRequest = new PartsRequest();
            partsRequest.setTicketId(ticketId);
            partsRequest.setRequestedBy(technicianId);
            partsRequest.setRequestDate(java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            partsRequest.setStatus(PartsRequest.RequestStatus.PENDING);
            partsRequest.setNotes(notes);
            // TODO: Set priority enum

            // ========== BƯỚC 3: TẠO DANH SÁCH LINH KIỆN ==========
            List<PartsRequestItem> items = new ArrayList<>();
            for (int i = 0; i < partNames.length; i++) {
                if (partNames[i] != null && !partNames[i].trim().isEmpty()) {
                    PartsRequestItem item = new PartsRequestItem();
                    item.setPartName(partNames[i].trim());
                    item.setPartCode(partCodes[i] != null ? partCodes[i].trim() : "");
                    item.setQuantityRequested(Integer.parseInt(quantities[i]));
                    item.setNotes(partNotes[i] != null ? partNotes[i].trim() : "");
                    items.add(item);
                    
                    System.out.println("  Item " + (i+1) + ": " + partNames[i] + " - Qty: " + quantities[i]);
                }
            }

            System.out.println("Total items created: " + items.size());

            if (items.isEmpty()) {
                throw new IllegalArgumentException("Phải có ít nhất 1 linh kiện hợp lệ!");
            }

            // ========== BƯỚC 4: LƯU VÀO DATABASE ==========
            System.out.println("========== Calling partsRequestDAO.createRequest() ==========");
            boolean success = partsRequestDAO.createRequest(partsRequest, items);
            System.out.println("Result: " + (success ? "SUCCESS ✓" : "FAILED ✗"));
            System.out.println("Generated Request ID: " + partsRequest.getRequestId());
            System.out.println("========== REQUEST PARTS: KẾT THÚC ==========");

            if (success) {
                // TODO: Send notification to warehouse staff
                // TODO: Update ticket status to WAITING_PARTS
                
                String successMsg = "Đã gửi yêu cầu " + items.size() + " loại linh kiện tới kho! (ID: " + partsRequest.getRequestId() + ")";
                System.out.println("✓ " + successMsg);
                request.getSession().setAttribute("successMessage", successMsg);
                response.sendRedirect(request.getContextPath() + "/technician/request-parts");
            } else {
                System.err.println("✗ FAILED: createRequest returned false");
                throw new Exception("Không thể tạo yêu cầu linh kiện!");
            }

        } catch (IllegalArgumentException e) {
            System.err.println("✗ IllegalArgumentException: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (SQLException e) {
            System.err.println("✗ SQLException: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi database: " + e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            System.err.println("✗ Exception: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
