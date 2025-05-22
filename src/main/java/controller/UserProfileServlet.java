package controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import dao.UserDAO;
import mode.User;

@WebServlet("/UserProfileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 5,   // 5 MB
    maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class UserProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        UserDAO userDAO = new UserDAO();
        
        if ("updateProfile".equals(action)) {
            // Update profile information
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String bio = request.getParameter("bio");
            
            // Validate input
            if (firstName == null || firstName.trim().isEmpty() || 
                lastName == null || lastName.trim().isEmpty() || 
                email == null || email.trim().isEmpty()) {
                session.setAttribute("errorMessage", "All required fields must be filled out");
                response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                return;
            }
            
            // Check if email is already in use by another user
            User existingUser = userDAO.findByEmail(email);
            if (existingUser != null && existingUser.getUserId() != user.getUserId()) {
                session.setAttribute("errorMessage", "Email is already in use by another user");
                response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                return;
            }
            
            // Update user object
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setEmail(email);
            user.setBio(bio);
            
            // Update in database
            boolean updated = userDAO.updateUser(user);
            
            if (updated) {
                // Update session
                session.setAttribute("user", user);
                session.setAttribute("successMessage", "Profile updated successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to update profile");
            }
            
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
            
        } else if ("changePassword".equals(action)) {
            // Change password
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            
            // Validate input
            if (currentPassword == null || currentPassword.trim().isEmpty() || 
                newPassword == null || newPassword.trim().isEmpty() || 
                confirmPassword == null || confirmPassword.trim().isEmpty()) {
                session.setAttribute("errorMessage", "All password fields must be filled out");
                response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                return;
            }
            
            // Check if passwords match
            if (!newPassword.equals(confirmPassword)) {
                session.setAttribute("errorMessage", "New passwords do not match");
                response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                return;
            }
            
            // Verify current password
            try {
                boolean passwordVerified = userDAO.verifyPassword(user.getUserId(), currentPassword);
                if (!passwordVerified) {
                    session.setAttribute("errorMessage", "Current password is incorrect");
                    response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                    return;
                }
                
                // Update password
                boolean updated = userDAO.updatePassword(user.getUserId(), newPassword);
                
                if (updated) {
                    session.setAttribute("successMessage", "Password changed successfully");
                } else {
                    session.setAttribute("errorMessage", "Failed to change password");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Error: " + e.getMessage());
            }
            
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
            
        } else if ("updateAvatar".equals(action)) {
            // Update profile picture
            try {
                Part filePart = request.getPart("avatarFile");
                
                if (filePart == null || filePart.getSize() == 0) {
                    session.setAttribute("errorMessage", "No file was uploaded");
                    response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                    return;
                }
                
                // Validate file type
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
                
                if (!fileExtension.equals("jpg") && !fileExtension.equals("jpeg") && 
                    !fileExtension.equals("png") && !fileExtension.equals("gif")) {
                    session.setAttribute("errorMessage", "Only image files (JPG, PNG, GIF) are allowed");
                    response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                    return;
                }
                
                // Create directory if it doesn't exist
                String uploadDir = getServletContext().getRealPath("/") + "uploads/profile-images/";
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) {
                    uploadDirFile.mkdirs();
                }
                
                // Generate unique filename
                String uniqueFileName = "user_" + user.getUserId() + "_" + System.currentTimeMillis() + "." + fileExtension;
                Path filePath = Paths.get(uploadDir + uniqueFileName);
                
                // Save file
                try (InputStream fileContent = filePart.getInputStream()) {
                    Files.copy(fileContent, filePath, StandardCopyOption.REPLACE_EXISTING);
                }
                
                // Update user profile image path in database
                String relativePath = "uploads/profile-images/" + uniqueFileName;
                user.setProfileImage(relativePath);
                
                boolean updated = userDAO.updateUser(user);
                
                if (updated) {
                    // Update session
                    session.setAttribute("user", user);
                    session.setAttribute("successMessage", "Profile picture updated successfully");
                } else {
                    session.setAttribute("errorMessage", "Failed to update profile picture");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Error uploading file: " + e.getMessage());
            }
            
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
        } else {
            // Invalid action
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
        }
    }
}
