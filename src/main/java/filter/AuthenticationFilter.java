package filter;


import mode.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

@WebFilter(urlPatterns = {"/admin/*", "/author/*", "/user/*"})
public class AuthenticationFilter implements Filter {
    private static final Logger LOGGER = Logger.getLogger(AuthenticationFilter.class.getName());
    
    // List of public URLs that don't require authentication
    private static final List<String> PUBLIC_URLS = Arrays.asList(
            "/index.jsp", "/login.jsp", "/register.jsp", "/about_us.jsp", "/contact_us.jsp",
            "/browsebook.jsp", "/bookdetails.jsp", "/LoginServlet", "/RegisterServlet",
            "/LogoutServlet", "/css/", "/js/", "/assets/", "/favicon.ico"
    );
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String relativePath = requestURI.substring(contextPath.length());
        
        // Check if the requested URL is public
        boolean isPublicURL = PUBLIC_URLS.stream()
                .anyMatch(url -> relativePath.equals(url) || relativePath.startsWith(url));
        
        if (isPublicURL) {
            // If it's a public URL, continue the filter chain
            chain.doFilter(request, response);
            return;
        }
        
        // Get the session
        HttpSession session = httpRequest.getSession(false);
        
        // Check if user is logged in
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        
        if (!isLoggedIn) {
            // If not logged in, redirect to login page
            httpResponse.sendRedirect(contextPath + "/login.jsp");
            return;
        }
        
        // Check role-based access
        User user = (User) session.getAttribute("user");
        
        if (relativePath.startsWith("/admin/") && user.getRole() != User.Role.ADMIN) {
            // If trying to access admin area without admin role
            httpResponse.sendRedirect(contextPath + "/access-denied.jsp");
            return;
        }
        
        if (relativePath.startsWith("/author/") && 
                (user.getRole() != User.Role.AUTHOR && user.getRole() != User.Role.ADMIN)) {
            // If trying to access author area without author or admin role
            httpResponse.sendRedirect(contextPath + "/access-denied.jsp");
            return;
        }
        
        // Continue the filter chain
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}