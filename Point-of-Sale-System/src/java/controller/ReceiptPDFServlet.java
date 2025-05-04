/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import com.itextpdf.kernel.pdf.*;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.*;
import com.itextpdf.layout.property.TextAlignment;

@WebServlet("/print-receipt")
public class ReceiptPDFServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=receipt.pdf");

        try (OutputStream os = response.getOutputStream()) {
            PdfWriter writer = new PdfWriter(os);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            document.add(new Paragraph("Swift POS System")
                    .setBold()
                    .setFontSize(18)
                    .setTextAlignment(TextAlignment.CENTER));
            document.add(new Paragraph("123/2, High level Road, Homagama\nTel: (+94) 76-2375055\n\n"));

            document.add(new Paragraph("Receipt #: INV-20250504-001"));
            document.add(new Paragraph("Date: " + java.time.LocalDateTime.now()));
            document.add(new Paragraph("Cashier: John Doe\n"));

            document.add(new Paragraph("Items:\n"));
            Table table = new Table(new float[]{4, 2, 2});
            table.setWidthPercent(100);
            table.addHeaderCell("Item");
            table.addHeaderCell("Qty");
            table.addHeaderCell("Price");

            // Example items — replace with actual cart data if needed
            table.addCell("T-Shirt");
            table.addCell("2");
            table.addCell("Rs. 5000");

            table.addCell("Notebook");
            table.addCell("1");
            table.addCell("Rs. 400");

            document.add(table);
            document.add(new Paragraph("\nSubtotal: Rs. 5400"));
            document.add(new Paragraph("Discount: Rs. 0"));
            document.add(new Paragraph("Total: Rs. 5400").setBold());

            document.add(new Paragraph("\nThank you for shopping with us!"));

            document.close();
        } catch (Exception e) {
            throw new ServletException("PDF generation error", e);
        }
    }
}
