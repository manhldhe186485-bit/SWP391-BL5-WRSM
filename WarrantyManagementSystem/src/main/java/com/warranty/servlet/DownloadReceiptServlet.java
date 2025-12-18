package com.warranty.servlet;

import com.warranty.dao.RepairTicketDAO;
import com.warranty.model.RepairTicket;
import com.warranty.util.ReceiptPDFGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;

/**
 * Servlet to download receipt PDF
 */
@WebServlet("/technician/download-receipt")
public class DownloadReceiptServlet extends HttpServlet {

    private RepairTicketDAO ticketDAO = new RepairTicketDAO();
    private ReceiptPDFGenerator pdfGenerator = new ReceiptPDFGenerator();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get ticket ID from parameter
            String ticketIdParam = request.getParameter("ticketId");
            if (ticketIdParam == null || ticketIdParam.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing ticket ID");
                return;
            }

            int ticketId = Integer.parseInt(ticketIdParam);
            
            // Get ticket from database
            RepairTicket ticket = ticketDAO.getTicketById(ticketId);
            if (ticket == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Ticket not found");
                return;
            }

            // Generate PDF
            byte[] pdfBytes = pdfGenerator.generateReceiptPDF(ticket);

            // Set response headers for PDF download
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"Phieu_Tiep_Nhan_" + ticket.getTicketNumber() + ".pdf\"");
            response.setContentLength(pdfBytes.length);

            // Write PDF to response
            try (OutputStream out = response.getOutputStream()) {
                out.write(pdfBytes);
                out.flush();
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ticket ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error generating PDF: " + e.getMessage());
        }
    }
}
