package com.warranty.servlet;

import com.warranty.dao.RepairTicketDAO;
import com.warranty.dao.InvoiceDAO;
import com.warranty.dao.PartsRequestDAO;
import com.warranty.dao.RepairProgressLogDAO;
import com.warranty.service.RepairTicketService;
import com.warranty.model.RepairTicket;
import com.warranty.model.Invoice;
import com.warranty.model.PartsRequest;
import com.warranty.model.RepairProgressLog;
import com.warranty.model.User;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/technician/create-invoice")
public class CreateInvoiceServlet extends HttpServlet {
    private RepairTicketDAO repairTicketDAO = new RepairTicketDAO();
    private RepairTicketService repairTicketService = new RepairTicketService();
    private InvoiceDAO invoiceDAO = new InvoiceDAO();
    private PartsRequestDAO partsRequestDAO = new PartsRequestDAO();
    private RepairProgressLogDAO progressLogDAO = new RepairProgressLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("DEBUG - CreateInvoiceServlet.doGet() called");
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        System.out.println("DEBUG - Session: " + (session != null ? "exists" : "null"));
        System.out.println("DEBUG - User: " + (user != null ? user.getUsername() : "null"));
        System.out.println("DEBUG - Role: " + (user != null ? user.getRole() : "null"));
        
        // if (user == null || !user.getRole().equals("TECHNICIAN")) {
        //     System.out.println("DEBUG - Redirecting to login - user is null or not TECHNICIAN");
        //     response.sendRedirect(request.getContextPath() + "/login");
        //     return;
        // }
        
        // ========== LẤY TICKETS TỪ REPAIR_PROGRESS_LOGS ==========
        System.out.println("========== LOADING COMPLETED TICKETS FROM LOGS ==========");
        
        // Lấy tất cả logs có status = 'COMPLETED' của technician này
        List<RepairProgressLog> completedLogs = progressLogDAO.getCompletedLogsByTechnician(user.getUserId());
        System.out.println("DEBUG - Found " + completedLogs.size() + " COMPLETED logs");
        
        // Lấy danh sách ticket_id duy nhất (loại bỏ trùng lặp)
        Set<Integer> ticketIds = new HashSet<>();
        for (RepairProgressLog log : completedLogs) {
            ticketIds.add(log.getTicketId());
        }
        System.out.println("DEBUG - Unique ticket IDs: " + ticketIds.size());
        
        // Load thông tin chi tiết của từng ticket (dùng Service để auto-load Customer và ProductSerial)
        List<RepairTicket> completedTickets = new ArrayList<>();
        for (Integer ticketId : ticketIds) {
            RepairTicket ticket = repairTicketService.getTicketById(ticketId);
            if (ticket != null) {
                completedTickets.add(ticket);
                System.out.println("  - Loaded ticket: " + ticket.getTicketNumber());
                System.out.println("    Ticket object: " + ticket);
                System.out.println("    Customer object: " + ticket.getCustomer());
                System.out.println("    Customer is null? " + (ticket.getCustomer() == null));
                if (ticket.getCustomer() != null) {
                    System.out.println("    Customer ID: " + ticket.getCustomer().getCustomerId());
                    System.out.println("    Customer Name: " + ticket.getCustomer().getFullName());
                }
                System.out.println("    ProductSerial object: " + ticket.getProductSerial());
                System.out.println("    ProductSerial is null? " + (ticket.getProductSerial() == null));
                if (ticket.getProductSerial() != null) {
                    System.out.println("    Serial Number: " + ticket.getProductSerial().getSerialNumber());
                    System.out.println("    Product object: " + ticket.getProductSerial().getProduct());
                    if (ticket.getProductSerial().getProduct() != null) {
                        System.out.println("    Product Name: " + ticket.getProductSerial().getProduct().getProductName());
                    }
                }
            }
        }
        
        System.out.println("DEBUG - Total completed tickets to display: " + completedTickets.size());
        System.out.println("=======================================================");
        
        request.setAttribute("completedTickets", completedTickets);
        
        request.getRequestDispatcher("/views/technician/create-invoice.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        


        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createInvoice(request, response, user);
        } else if ("export".equals(action)) {
            // Export từ request parameter (dùng cho việc export lại sau)
            int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
            exportInvoiceToExcelById(response, invoiceId);
        }
    }

    private void createInvoice(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        try {
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            BigDecimal laborCost = new BigDecimal(request.getParameter("laborCost"));
            BigDecimal partsCost = new BigDecimal(request.getParameter("partsCost"));
            String notes = request.getParameter("notes");

            System.out.println("========== CREATE INVOICE ==========");
            System.out.println("Ticket ID: " + ticketId);
            System.out.println("Labor Cost: " + laborCost);
            System.out.println("Parts Cost: " + partsCost);
            System.out.println("Notes: " + notes);

            // Calculate total
            BigDecimal totalAmount = laborCost.add(partsCost);
            System.out.println("Total Amount: " + totalAmount);

            // Create invoice
            Invoice invoice = new Invoice();
            invoice.setTicketId(ticketId);
            invoice.setLaborCost(laborCost);
            invoice.setPartsCost(partsCost);
            invoice.setTotalAmount(totalAmount);
            invoice.setNotes(notes);
            invoice.setCreatedBy(user.getUserId());
            invoice.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            invoice.setStatus("PENDING");

            boolean success = invoiceDAO.createInvoice(invoice);
            System.out.println("Invoice created: " + success);

            if (success) {
                // Lấy invoice vừa tạo để có invoiceId
                System.out.println("Invoice ID after creation: " + invoice.getInvoiceId());
                
                // Tự động xuất Excel sau khi tạo thành công
                if (invoice.getInvoiceId() > 0) {
                    System.out.println("Auto-exporting Excel for invoice ID: " + invoice.getInvoiceId());
                    exportInvoiceToExcelById(response, invoice.getInvoiceId());
                } else {
                    System.err.println("ERROR - Invoice ID not set after creation!");
                    response.sendRedirect(request.getContextPath() + "/technician/create-invoice?success=true");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/technician/create-invoice?error=true");
            }
            System.out.println("====================================");
        } catch (Exception e) {
            System.err.println("ERROR - Exception in createInvoice:");
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/technician/create-invoice?error=true");
        }
    }

    private void exportInvoiceToExcelById(HttpServletResponse response, int invoiceId)
            throws ServletException, IOException {
        try {
            System.out.println("========== EXPORT INVOICE TO EXCEL ==========");
            System.out.println("Invoice ID: " + invoiceId);
            
            Invoice invoice = invoiceDAO.getInvoiceById(invoiceId);
            
            if (invoice == null) {
                System.err.println("ERROR - Invoice not found: " + invoiceId);
                return;
            }
            
            System.out.println("Invoice found: INV-" + invoice.getInvoiceId());
            System.out.println("Ticket: " + invoice.getTicketNumber());
            
            // Load RepairTicket để lấy thông tin sản phẩm và khách hàng
            RepairTicket ticket = null;
            if (invoice.getTicketId() > 0) {
                ticket = repairTicketService.getTicketById(invoice.getTicketId());
            }

            // Create Excel workbook
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Phiếu Thanh Toán");

            // Create styles
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 14);
            headerStyle.setFont(headerFont);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);

            CellStyle boldStyle = workbook.createCellStyle();
            Font boldFont = workbook.createFont();
            boldFont.setBold(true);
            boldStyle.setFont(boldFont);

            CellStyle currencyStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            currencyStyle.setDataFormat(format.getFormat("#,##0 ₫"));

            // Header
            Row row0 = sheet.createRow(0);
            Cell titleCell = row0.createCell(0);
            titleCell.setCellValue("PHIẾU THANH TOÁN BẢO HÀNH");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 3));

            // Invoice info
            int rowNum = 2;
            createRow(sheet, rowNum++, "Mã phiếu:", "INV-" + invoice.getInvoiceId(), boldStyle, null);
            createRow(sheet, rowNum++, "Mã đơn BH:", invoice.getTicketNumber(), boldStyle, null);
            createRow(sheet, rowNum++, "Ngày tạo:", new SimpleDateFormat("dd/MM/yyyy HH:mm").format(invoice.getCreatedAt()), boldStyle, null);
            createRow(sheet, rowNum++, "Người tạo:", invoice.getCreatorName(), boldStyle, null);
            
            // Thông tin sản phẩm và khách hàng
            String productName = "N/A";
            String customerName = "N/A";
            if (ticket != null) {
                if (ticket.getProductSerial() != null && ticket.getProductSerial().getProduct() != null) {
                    productName = ticket.getProductSerial().getProduct().getProductName();
                }
                if (ticket.getCustomer() != null) {
                    customerName = ticket.getCustomer().getFullName();
                }
            }
            createRow(sheet, rowNum++, "Sản phẩm:", productName, boldStyle, null);
            createRow(sheet, rowNum++, "Khách hàng:", customerName, boldStyle, null);

            rowNum++; // Empty row

            // Cost breakdown
            Row headerRow = sheet.createRow(rowNum++);
            headerRow.createCell(0).setCellValue("Hạng mục");
            headerRow.createCell(1).setCellValue("Số tiền");
            headerRow.getCell(0).setCellStyle(boldStyle);
            headerRow.getCell(1).setCellStyle(boldStyle);

            Row laborRow = sheet.createRow(rowNum++);
            laborRow.createCell(0).setCellValue("Phí dịch vụ");
            Cell laborCell = laborRow.createCell(1);
            laborCell.setCellValue(invoice.getLaborCost().doubleValue());
            laborCell.setCellStyle(currencyStyle);

            Row partsRow = sheet.createRow(rowNum++);
            partsRow.createCell(0).setCellValue("Chi phí linh kiện");
            Cell partsCell = partsRow.createCell(1);
            partsCell.setCellValue(invoice.getPartsCost().doubleValue());
            partsCell.setCellStyle(currencyStyle);

            rowNum++; // Empty row

            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(0).setCellValue("TỔNG CỘNG");
            Cell totalCell = totalRow.createCell(1);
            totalCell.setCellValue(invoice.getTotalAmount().doubleValue());
            totalRow.getCell(0).setCellStyle(boldStyle);
            totalCell.setCellStyle(currencyStyle);

            // Notes
            if (invoice.getNotes() != null && !invoice.getNotes().isEmpty()) {
                rowNum++;
                Row notesLabelRow = sheet.createRow(rowNum++);
                notesLabelRow.createCell(0).setCellValue("Ghi chú:");
                notesLabelRow.getCell(0).setCellStyle(boldStyle);
                
                Row notesRow = sheet.createRow(rowNum++);
                notesRow.createCell(0).setCellValue(invoice.getNotes());
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 3));
            }

            // Auto-size columns
            for (int i = 0; i < 4; i++) {
                sheet.autoSizeColumn(i);
            }

            // Set response headers
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=Invoice_" + invoice.getInvoiceId() + ".xlsx");

            // Write to output stream
            OutputStream outputStream = response.getOutputStream();
            workbook.write(outputStream);
            workbook.close();
            outputStream.close();
            
            System.out.println("Excel file exported successfully: Invoice_" + invoice.getInvoiceId() + ".xlsx");
            System.out.println("=============================================");

        } catch (Exception e) {
            System.err.println("ERROR - Exception in exportInvoiceToExcelById:");
            e.printStackTrace();
        }
    }

    private void createRow(Sheet sheet, int rowNum, String label, String value, CellStyle labelStyle, CellStyle valueStyle) {
        Row row = sheet.createRow(rowNum);
        Cell labelCell = row.createCell(0);
        labelCell.setCellValue(label);
        if (labelStyle != null) {
            labelCell.setCellStyle(labelStyle);
        }
        
        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value);
        if (valueStyle != null) {
            valueCell.setCellStyle(valueStyle);
        }
    }
}
