package com.warranty.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class TestImportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.getWriter().println("<h1>Test Import Page Works!</h1>");
        response.getWriter().println("<p>ImportExcel servlet sẽ hoạt động tại đây.</p>");
        response.getWriter().println("<a href='/admin/dashboard'>Quay lại Dashboard</a>");
    }
}