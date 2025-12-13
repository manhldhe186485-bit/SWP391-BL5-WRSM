package com.warranty.servlet;

import com.warranty.dao.PartsRequestDAO;
import com.warranty.model.PartsRequest;
import com.warranty.model.PartsRequestItem;

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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ========== LẤY LỊCH SỬ YÊU CẦU CỦA TECHNICIAN ==========
        try {
            Integer technicianId = (Integer) request.getSession().getAttribute("userId");
            List<PartsRequest> myRequests = partsRequestDAO.getRequestsByTechnician(technicianId);
            
            request.setAttribute("myRequests", myRequests);
        } catch (SQLException e) {
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
            // ========== BƯỚC 1: LẤY THÔNG TIN TỪ FORM ==========
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String priority = request.getParameter("priority");
            String notes = request.getParameter("notes");

            // Get array of parts
            String[] partNames = request.getParameterValues("partName[]");
            String[] partCodes = request.getParameterValues("partCode[]");
            String[] quantities = request.getParameterValues("quantity[]");
            String[] partNotes = request.getParameterValues("partNote[]");

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
                }
            }

            if (items.isEmpty()) {
                throw new IllegalArgumentException("Phải có ít nhất 1 linh kiện hợp lệ!");
            }

            // ========== BƯỚC 4: LƯU VÀO DATABASE ==========
            boolean success = partsRequestDAO.createRequest(partsRequest, items);

            if (success) {
                // TODO: Send notification to warehouse staff
                // TODO: Update ticket status to WAITING_PARTS
                
                request.getSession().setAttribute("successMessage", 
                    "Đã gửi yêu cầu " + items.size() + " loại linh kiện tới kho!");
                response.sendRedirect(request.getContextPath() + "/technician/request-parts");
            } else {
                throw new Exception("Không thể tạo yêu cầu linh kiện!");
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
