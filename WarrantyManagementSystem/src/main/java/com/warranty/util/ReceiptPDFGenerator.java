package com.warranty.util;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.pdf.draw.LineSeparator;
import com.warranty.model.Customer;
import com.warranty.model.ProductSerial;
import com.warranty.model.RepairTicket;
import com.warranty.dao.CustomerDAO;
import com.warranty.dao.ProductSerialDAO;
import com.warranty.dao.ProductDAO;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Utility class to generate PDF receipts for warranty/repair tickets
 */
public class ReceiptPDFGenerator {

    private static final Font FONT_TITLE = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
    private static final Font FONT_HEADER = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
    private static final Font FONT_NORMAL = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL);
    private static final Font FONT_BOLD = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD);
    private static final Font FONT_SMALL = new Font(Font.FontFamily.HELVETICA, 9, Font.ITALIC);

    private CustomerDAO customerDAO = new CustomerDAO();
    private ProductSerialDAO productSerialDAO = new ProductSerialDAO();
    private ProductDAO productDAO = new ProductDAO();

    /**
     * Generate PDF receipt for repair ticket
     * @param ticket RepairTicket object
     * @return byte array of PDF content
     */
    public byte[] generateReceiptPDF(RepairTicket ticket) throws DocumentException, IOException {
        Document document = new Document(PageSize.A4, 50, 50, 50, 50);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        try {
            PdfWriter.getInstance(document, baos);
            document.open();

            // Get related data
            Customer customer = customerDAO.getCustomerById(ticket.getCustomerId());
            ProductSerial serial = null;
            try {
                serial = productSerialDAO.getBySerialId(ticket.getSerialId());
            } catch (Exception e) {
                e.printStackTrace();
            }
            String productName = "N/A";
            if (serial != null && serial.getProductId() > 0) {
                var product = productDAO.getProductById(serial.getProductId());
                if (product != null) {
                    productName = product.getName();
                }
            }

            // ========== HEADER ==========
            addHeader(document, ticket);
            
            document.add(Chunk.NEWLINE);
            
            // ========== TICKET INFO ==========
            addTicketInfo(document, ticket);
            
            document.add(Chunk.NEWLINE);
            
            // ========== CUSTOMER INFO ==========
            addCustomerInfo(document, customer);
            
            document.add(Chunk.NEWLINE);
            
            // ========== PRODUCT INFO ==========
            addProductInfo(document, serial, productName, ticket);
            
            document.add(Chunk.NEWLINE);
            
            // ========== ISSUE DESCRIPTION ==========
            addIssueDescription(document, ticket);
            
            document.add(Chunk.NEWLINE);
            document.add(Chunk.NEWLINE);
            
            // ========== FOOTER ==========
            addFooter(document);

            document.close();
            
        } catch (Exception e) {
            if (document.isOpen()) {
                document.close();
            }
            throw e;
        }

        return baos.toByteArray();
    }

    /**
     * Save PDF to file
     */
    public void savePDFToFile(RepairTicket ticket, String filePath) throws DocumentException, IOException {
        byte[] pdfBytes = generateReceiptPDF(ticket);
        try (FileOutputStream fos = new FileOutputStream(filePath)) {
            fos.write(pdfBytes);
        }
    }

    private void addHeader(Document document, RepairTicket ticket) throws DocumentException {
        // Company name
        Paragraph company = new Paragraph("HE THONG BAO HANH THIET BI DIEN TU", FONT_TITLE);
        company.setAlignment(Element.ALIGN_CENTER);
        document.add(company);
        
        // Document title
        Paragraph title = new Paragraph("PHIEU TIEP NHAN SAN PHAM", FONT_HEADER);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(5);
        document.add(title);
        
        // Ticket number
        Paragraph ticketNum = new Paragraph("Ma phieu: " + ticket.getTicketNumber(), FONT_BOLD);
        ticketNum.setAlignment(Element.ALIGN_CENTER);
        ticketNum.setSpacingAfter(10);
        document.add(ticketNum);
        
        // Line separator
        LineSeparator line = new LineSeparator();
        document.add(new Chunk(line));
    }

    private void addTicketInfo(Document document, RepairTicket ticket) throws DocumentException {
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10);
        
        // Ticket Type
        addTableRow(table, "Loai phieu:", 
            ticket.getTicketType() == RepairTicket.TicketType.WARRANTY ? "BAO HANH" : "SUA CHUA TRA PHI");
        
        // Received Date
        addTableRow(table, "Ngay tiep nhan:", 
            dateFormat.format(ticket.getReceivedDate()));
        
        // Status
        addTableRow(table, "Trang thai:", getStatusText(ticket.getStatus()));
        
        // Priority
        addTableRow(table, "Do uu tien:", getPriorityText(ticket.getPriority()));
        
        document.add(table);
    }

    private void addCustomerInfo(Document document, Customer customer) throws DocumentException {
        Paragraph header = new Paragraph("THONG TIN KHACH HANG", FONT_HEADER);
        header.setSpacingBefore(10);
        document.add(header);
        
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setSpacingBefore(5);
        
        if (customer != null) {
            addTableRow(table, "Ho va ten:", customer.getFullName());
            addTableRow(table, "So dien thoai:", customer.getPhone());
            addTableRow(table, "Email:", customer.getEmail() != null ? customer.getEmail() : "");
            addTableRow(table, "Dia chi:", customer.getAddress() != null ? customer.getAddress() : "");
        } else {
            addTableRow(table, "Thong tin:", "Khong co thong tin khach hang");
        }
        
        document.add(table);
    }

    private void addProductInfo(Document document, ProductSerial serial, String productName, RepairTicket ticket) throws DocumentException {
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        
        Paragraph header = new Paragraph("THONG TIN SAN PHAM", FONT_HEADER);
        header.setSpacingBefore(10);
        document.add(header);
        
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setSpacingBefore(5);
        
        if (serial != null) {
            addTableRow(table, "Ten san pham:", productName);
            addTableRow(table, "So serial:", serial.getSerialNumber());
            
            if (serial.getPurchaseDate() != null) {
                addTableRow(table, "Ngay mua:", dateFormat.format(serial.getPurchaseDate()));
            }
            
            if (serial.getWarrantyEndDate() != null) {
                addTableRow(table, "Bao hanh den:", dateFormat.format(serial.getWarrantyEndDate()));
                
                // Check warranty status
                Date today = new Date();
                boolean isUnderWarranty = today.before(serial.getWarrantyEndDate());
                addTableRow(table, "Tinh trang BH:", 
                    isUnderWarranty ? "CON BAO HANH" : "HET BAO HANH");
            }
        } else {
            addTableRow(table, "Thong tin:", "Khong co thong tin san pham");
        }
        
        document.add(table);
    }

    private void addIssueDescription(Document document, RepairTicket ticket) throws DocumentException {
        Paragraph header = new Paragraph("MO TA LOI", FONT_HEADER);
        header.setSpacingBefore(10);
        document.add(header);
        
        Paragraph description = new Paragraph(
            ticket.getIssueDescription() != null ? ticket.getIssueDescription() : "Khong co mo ta",
            FONT_NORMAL
        );
        description.setSpacingBefore(5);
        description.setAlignment(Element.ALIGN_JUSTIFIED);
        document.add(description);
    }

    private void addFooter(Document document) throws DocumentException {
        // Line separator
        LineSeparator line = new LineSeparator();
        document.add(new Chunk(line));
        
        document.add(Chunk.NEWLINE);
        
        // Signature section
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        
        // Customer signature
        PdfPCell customerCell = new PdfPCell();
        customerCell.setBorder(Rectangle.NO_BORDER);
        Paragraph customerSig = new Paragraph("KHACH HANG\n(Ky va ghi ro ho ten)\n\n\n\n", FONT_BOLD);
        customerSig.setAlignment(Element.ALIGN_CENTER);
        customerCell.addElement(customerSig);
        table.addCell(customerCell);
        
        // Staff signature
        PdfPCell staffCell = new PdfPCell();
        staffCell.setBorder(Rectangle.NO_BORDER);
        Paragraph staffSig = new Paragraph("NHAN VIEN TIEP NHAN\n(Ky va ghi ro ho ten)\n\n\n\n", FONT_BOLD);
        staffSig.setAlignment(Element.ALIGN_CENTER);
        staffCell.addElement(staffSig);
        table.addCell(staffCell);
        
        document.add(table);
        
        // Notes
        Paragraph notes = new Paragraph(
            "Luu y: Vui long giu phieu nay de theo doi qua trinh sua chua va nhan lai san pham.",
            FONT_SMALL
        );
        notes.setAlignment(Element.ALIGN_CENTER);
        notes.setSpacingBefore(20);
        document.add(notes);
        
        // Date
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        Paragraph date = new Paragraph("Ngay lap phieu: " + dateFormat.format(new Date()), FONT_SMALL);
        date.setAlignment(Element.ALIGN_CENTER);
        date.setSpacingBefore(10);
        document.add(date);
    }

    private void addTableRow(PdfPTable table, String label, String value) {
        // Label cell
        PdfPCell labelCell = new PdfPCell(new Phrase(label, FONT_BOLD));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setPaddingBottom(5);
        labelCell.setHorizontalAlignment(Element.ALIGN_LEFT);
        table.addCell(labelCell);
        
        // Value cell
        PdfPCell valueCell = new PdfPCell(new Phrase(value, FONT_NORMAL));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setPaddingBottom(5);
        valueCell.setHorizontalAlignment(Element.ALIGN_LEFT);
        table.addCell(valueCell);
    }

    private String getStatusText(RepairTicket.TicketStatus status) {
        switch (status) {
            case PENDING_ASSIGNMENT: return "Cho phan cong";
            case ASSIGNED: return "Da phan cong";
            case IN_DIAGNOSIS: return "Dang chan doan";
            case IN_PROGRESS: return "Dang sua chua";
            case WAITING_PARTS: return "Cho linh kien";
            case COMPLETED: return "Hoan thanh";
            case DELIVERED: return "Da giao";
            case CANCELLED: return "Da huy";
            default: return status.toString();
        }
    }

    private String getPriorityText(RepairTicket.Priority priority) {
        if (priority == null) return "BINH THUONG";
        switch (priority) {
            case LOW: return "THAP";
            case MEDIUM: return "BINH THUONG";
            case HIGH: return "CAO";
            case URGENT: return "KHAN CAP";
            default: return priority.toString();
        }
    }
}
