/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller; // Your actual package

import dao.CompanyDAO;
import model.ProductModel;
import model.SupplierModel;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet; // Ensure this import is present
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

// New, corrected WebServlet mapping
@WebServlet("/Admin/productsBySupplierController")
public class CompanyController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CompanyController.class.getName());
    private CompanyDAO companyDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        companyDAO = new CompanyDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response, false); // false for initial GET
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response, true); // true for POST (form submission)
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response, boolean isPost)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            List<SupplierModel> allSuppliers = companyDAO.getAllSuppliers();
            request.setAttribute("suppliersList", allSuppliers);

            String selectedSupplierIdParam = request.getParameter("supplierSelect");
            String categoryFilterParam = request.getParameter("categoryFilter");
            String minStockParam = request.getParameter("minStock");
            String minPriceParam = request.getParameter("minPrice");
            String maxPriceParam = request.getParameter("maxPrice");
            
            boolean formSubmittedOrFiltersPresent = isPost || 
                                                    (selectedSupplierIdParam != null && !selectedSupplierIdParam.isEmpty()) ||
                                                    (categoryFilterParam != null && !categoryFilterParam.isEmpty()) ||
                                                    (minStockParam != null && !minStockParam.isEmpty()) ||
                                                    (minPriceParam != null && !minPriceParam.isEmpty()) ||
                                                    (maxPriceParam != null && !maxPriceParam.isEmpty());
            
            request.setAttribute("formWasSubmitted", formSubmittedOrFiltersPresent);

            String supplierNameToFilterBy = null;
            String selectedSupplierNameToDisplay = "";

            if (selectedSupplierIdParam != null && !selectedSupplierIdParam.isEmpty()) {
                try {
                    int supplierId = Integer.parseInt(selectedSupplierIdParam);
                    SupplierModel selectedSupplierObj = companyDAO.getSupplierById(supplierId);
                    if (selectedSupplierObj != null) {
                        supplierNameToFilterBy = selectedSupplierObj.getCompanyName();
                        selectedSupplierNameToDisplay = selectedSupplierObj.getCompanyName();
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid supplier ID: " + selectedSupplierIdParam, e);
                }
            }
            request.setAttribute("selectedSupplierId", selectedSupplierIdParam != null ? selectedSupplierIdParam : "");
            request.setAttribute("selectedSupplierName", selectedSupplierNameToDisplay);

            String categoryToFilterBy = null;
            if (categoryFilterParam != null && !categoryFilterParam.isEmpty() && !categoryFilterParam.equalsIgnoreCase("All Categories")) {
                categoryToFilterBy = categoryFilterParam;
            }
            request.setAttribute("selectedCategory", categoryFilterParam != null ? categoryFilterParam : "");

            Integer minStockToFilterBy = null;
            if (minStockParam != null && !minStockParam.isEmpty()) {
                try { minStockToFilterBy = Integer.parseInt(minStockParam); } 
                catch (NumberFormatException e) { LOGGER.log(Level.WARNING, "Invalid min stock: " + minStockParam, e); }
            }
            request.setAttribute("enteredMinStock", minStockParam != null ? minStockParam : "");

            BigDecimal minPriceToFilterBy = null;
            if (minPriceParam != null && !minPriceParam.isEmpty()) {
                try { minPriceToFilterBy = new BigDecimal(minPriceParam); }
                catch (NumberFormatException e) { LOGGER.log(Level.WARNING, "Invalid min price: " + minPriceParam, e); }
            }
            request.setAttribute("enteredMinPrice", minPriceParam != null ? minPriceParam : "");

            BigDecimal maxPriceToFilterBy = null;
            if (maxPriceParam != null && !maxPriceParam.isEmpty()) {
                try { maxPriceToFilterBy = new BigDecimal(maxPriceParam); }
                catch (NumberFormatException e) { LOGGER.log(Level.WARNING, "Invalid max price: " + maxPriceParam, e); }
            }
            request.setAttribute("enteredMaxPrice", maxPriceParam != null ? maxPriceParam : "");

            List<ProductModel> productsToDisplay;

            if (!formSubmittedOrFiltersPresent && !isPost) {
                LOGGER.info("Initial page load for /Admin/productsBySupplierController. Fetching all active products.");
                productsToDisplay = companyDAO.getProductsByCriteria(null, null, null, null, null);
            } else {
                LOGGER.info("Form submitted or filters present for /Admin/productsBySupplierController. Fetching products with Supplier Name: " + supplierNameToFilterBy);
                productsToDisplay = companyDAO.getProductsByCriteria(
                        supplierNameToFilterBy,
                        categoryToFilterBy,
                        minStockToFilterBy,
                        minPriceToFilterBy,
                        maxPriceToFilterBy
                );
            }

            request.setAttribute("filteredProductsList", productsToDisplay);
            request.setAttribute("productsCount", productsToDisplay.size());

            // Ensure your products_by_supplier.jsp is in the /Admin/ folder relative to your webapp root
            request.getRequestDispatcher("/Admin/products_by_supplier.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in CompanyController (/Admin/productsBySupplierController): " + e.getMessage(), e);
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response); // Ensure you have an error.jsp
        }
    }
}