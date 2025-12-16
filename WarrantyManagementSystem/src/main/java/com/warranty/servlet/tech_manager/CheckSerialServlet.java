package com.warranty.servlet.tech_manager;

import com.warranty.dao.ProductSerialDAO;
import com.warranty.model.ProductSerial;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.time.temporal.ChronoUnit;

/**
 * API servlet to check if serial exists and return warranty info
 */
@WebServlet("/tech-manager/check-serial")
public class CheckSerialServlet extends HttpServlet {

    private ProductSerialDAO productSerialDAO = new ProductSerialDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String serialNumber = request.getParameter("serialNumber");
        PrintWriter out = response.getWriter();
        
        try {
            ProductSerial productSerial = productSerialDAO.getBySerialNumber(serialNumber);
            
            if (productSerial != null) {
                // Serial found - check warranty status
                Date warrantyEndDate = productSerial.getWarrantyEndDate();
                Date today = new Date(System.currentTimeMillis());
                boolean isUnderWarranty = warrantyEndDate != null && today.before(warrantyEndDate);
                
                // Calculate months remaining
                long monthsRemaining = 0;
                if (warrantyEndDate != null && isUnderWarranty) {
                    long daysRemaining = ChronoUnit.DAYS.between(
                        today.toLocalDate(), 
                        warrantyEndDate.toLocalDate()
                    );
                    monthsRemaining = daysRemaining / 30;
                }
                
                // Return JSON
                out.println("{");
                out.println("  \"found\": true,");
                out.println("  \"serialId\": " + productSerial.getSerialId() + ",");
                out.println("  \"productName\": \"" + escapeJson(productSerial.getProductName()) + "\",");
                out.println("  \"customerName\": \"" + escapeJson(productSerial.getCustomerName()) + "\",");
                out.println("  \"customerPhone\": \"" + escapeJson(productSerial.getCustomerPhone()) + "\",");
                out.println("  \"underWarranty\": " + isUnderWarranty + ",");
                out.println("  \"monthsRemaining\": " + monthsRemaining);
                out.println("}");
                
            } else {
                // Serial not found
                out.println("{");
                out.println("  \"found\": false,");
                out.println("  \"message\": \"Serial không tồn tại trong hệ thống\"");
                out.println("}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println("{");
            out.println("  \"error\": true,");
            out.println("  \"message\": \"" + escapeJson(e.getMessage()) + "\"");
            out.println("}");
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r");
    }
}
