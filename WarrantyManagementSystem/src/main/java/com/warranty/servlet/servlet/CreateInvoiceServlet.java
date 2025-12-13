package com.warranty.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.warranty.dao.RepairTicketDAO;
import com.warranty.model.RepairTicket;

@WebServlet("/technician/create-invoice")
public class CreateInvoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private RepairTicketDAO repairTicketDAO;

    @Override
    public void init() throws ServletException {
        repairTicketDAO = new RepairTicketDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Lấy các ticket đã hoàn thành để tạo hóa đơn
            List<RepairTicket> completedTickets = repairTicketDAO.getTicketsByTechnicianAndStatus(userId, "Completed");
            request.setAttribute("completedTickets", completedTickets);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải danh sách phiếu: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/technician/create-invoice.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String ticketIdStr = request.getParameter("ticketId");
            String serviceChargeStr = request.getParameter("serviceCharge");
            String partsChargeStr = request.getParameter("partsCharge");
            String notes = request.getParameter("notes");

            if (ticketIdStr == null || serviceChargeStr == null || partsChargeStr == null) {
                request.setAttribute("error", "Vui lòng điền đầy đủ thông tin");
                doGet(request, response);
                return;
            }

            int ticketId = Integer.parseInt(ticketIdStr);
            BigDecimal serviceCharge = new BigDecimal(serviceChargeStr);
            BigDecimal partsCharge = new BigDecimal(partsChargeStr);
            BigDecimal totalCost = serviceCharge.add(partsCharge);

            // Cập nhật thông tin thanh toán cho ticket
            boolean success = repairTicketDAO.updateInvoiceInfo(ticketId, serviceCharge, partsCharge, totalCost, notes);

            if (success) {
                request.setAttribute("message", "Tạo hóa đơn thành công!");
            } else {
                request.setAttribute("error", "Lỗi khi tạo hóa đơn!");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Định dạng số không hợp lệ");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi database: " + e.getMessage());
        }

        doGet(request, response);
    }
}