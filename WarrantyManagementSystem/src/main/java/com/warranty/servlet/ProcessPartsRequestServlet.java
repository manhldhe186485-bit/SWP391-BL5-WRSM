package com.warranty.servlet;

import com.warranty.dao.PartsRequestDAO;
import com.warranty.model.PartsRequest;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet for Warehouse staff to process parts requests
 */
@WebServlet("/warehouse/process-request")
public class ProcessPartsRequestServlet extends HttpServlet {

    private PartsRequestDAO partsRequestDAO = new PartsRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("WAREHOUSE") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ========== LẤY DANH SÁCH YÊU CẦU CHỜ DUYỆT ==========
        try {
            List<PartsRequest> pendingRequests = partsRequestDAO.getRequestsByStatus(
                PartsRequest.RequestStatus.PENDING.name()
            );

            request.setAttribute("pendingRequests", pendingRequests);

            // Forward to warehouse page
            request.getRequestDispatcher("/views/warehouse/process-request.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        Integer warehouseStaffId = (Integer) request.getSession().getAttribute("userId");
        
        if (role == null || (!role.equals("WAREHOUSE") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // ========== BƯỚC 1: LẤY THÔNG TIN ==========
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            String action = request.getParameter("action"); // "approve" or "reject"
            String notes = request.getParameter("notes");

            // Get approved quantities for each item
            String[] itemIds = request.getParameterValues("itemId[]");
            String[] approvedQty = request.getParameterValues("approvedQuantity[]");

            // ========== BƯỚC 2: KIỂM TRA YÊU CẦU ==========
            PartsRequest partsRequest = partsRequestDAO.getRequestById(requestId);
            
            if (partsRequest == null) {
                throw new IllegalArgumentException("Không tìm thấy yêu cầu!");
            }

            if (partsRequest.getStatus() != PartsRequest.RequestStatus.PENDING) {
                throw new IllegalStateException("Yêu cầu đã được xử lý rồi!");
            }

            // ========== BƯỚC 3: XỬ LÝ YÊU CẦU ==========
            boolean success;
            PartsRequest.RequestStatus newStatus;
            String message;

            if ("approve".equals(action)) {
                // DUYỆT YÊU CẦU
                newStatus = PartsRequest.RequestStatus.APPROVED;
                
                // TODO: Update approved quantities for each item
                // TODO: Reduce inventory quantities
                // TODO: Update ticket status to IN_PROGRESS (if was WAITING_PARTS)
                
                success = partsRequestDAO.updateRequestStatus(requestId, newStatus.name(), warehouseStaffId, notes);
                message = "Đã duyệt yêu cầu! Linh kiện đã được xuất kho.";
                
            } else if ("reject".equals(action)) {
                // TỪ CHỐI YÊU CẦU
                newStatus = PartsRequest.RequestStatus.REJECTED;
                
                success = partsRequestDAO.updateRequestStatus(requestId, newStatus.name(), warehouseStaffId, notes);
                message = "Đã từ chối yêu cầu. Lý do: " + notes;
                
            } else {
                throw new IllegalArgumentException("Hành động không hợp lệ!");
            }

            if (success) {
                // TODO: Send notification to technician
                
                request.getSession().setAttribute("successMessage", message);
                response.sendRedirect(request.getContextPath() + "/warehouse/process-request");
            } else {
                throw new Exception("Không thể xử lý yêu cầu!");
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
