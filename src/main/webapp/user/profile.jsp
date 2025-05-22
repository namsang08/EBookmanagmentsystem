<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User"%>
<%@ page import="mode.Review"%>
<%@ page import="dao.UserDAO"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="dao.ReviewDAO"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - E-Library Hub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .dashboard-container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: calc(100vh - 60px);
        }
        
        .sidebar {
            background-color: #2c3e50;
            color: white;
            padding: 20px 0;
        }
        
        .sidebar-header {
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 20px;
        }
        
        .sidebar-header h2 {
            font-size: 1.2rem;
            margin-bottom: 5px;
        }
        
        .sidebar-header p {
            font-size: 0.9rem;
            opacity: 0.7;
        }
        
        .sidebar-menu {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .sidebar-menu li {
            margin-bottom: 5px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 10px 20px;
            color: rgba(255, 255, 255, 0.7);
            transition: all 0.3s ease;
            text-decoration: none;
        }
        
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }
        
        .sidebar-menu i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }
        
        .main-content {
            padding: 20px;
            background-color: #f8f9fa;
        }
        
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .dashboard-title {
            font-size: 1.5rem;
            margin: 0;
        }
        
        .profile-container {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 20px;
        }
        
        .profile-sidebar {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .profile-avatar-container {
            position: relative;
            width: 150px;
            height: 150px;
            margin: 0 auto 20px;
        }
        
        .profile-avatar {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            display: block;
        }
        
        .avatar-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border-radius: 50%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
            cursor: pointer;
        }
        
        .avatar-overlay:hover {
            opacity: 1;
        }
        
        .avatar-overlay i {
            color: white;
            font-size: 1.5rem;
        }
        
        .profile-name {
            font-size: 1.2rem;
            font-weight: 600;
            text-align: center;
            margin-bottom: 5px;
        }
        
        .profile-role {
            color: #6c757d;
            text-align: center;
            margin-bottom: 20px;
        }
        
        .profile-stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .profile-stat {
            text-align: center;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }
        
        .profile-stat-value {
            font-size: 1.5rem;
            font-weight: 600;
        }
        
        .profile-stat-label {
            font-size: 0.8rem;
            color: #6c757d;
        }
        
        .profile-main {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .profile-section {
            margin-bottom: 30px;
        }
        
        .profile-section:last-child {
            margin-bottom: 0;
        }
        
        .profile-section-title {
            font-size: 1.2rem;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            font-size: 1rem;
        }
        
        .form-control:focus {
            border-color: #007bff;
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }
        
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
        
        .btn-primary {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
        }
        
        .btn-primary:hover {
            background-color: #0069d9;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .btn-danger {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-success {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
            border: 1px solid rgba(40, 167, 69, 0.2);
        }
        
        .alert-danger {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
            border: 1px solid rgba(220, 53, 69, 0.2);
        }
        
        .password-strength {
            height: 5px;
            margin-top: 5px;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        
        .password-strength.weak {
            background-color: #dc3545;
            width: 33%;
        }
        
        .password-strength.medium {
            background-color: #ffc107;
            width: 66%;
        }
        
        .password-strength.strong {
            background-color: #28a745;
            width: 100%;
        }
        
        .password-feedback {
            font-size: 0.8rem;
            margin-top: 5px;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
        }
        
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 0;
            border-radius: 8px;
            width: 500px;
            max-width: 90%;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }
        
        .modal-header {
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .modal-title {
            margin: 0;
            font-size: 1.25rem;
        }
        
        .modal-body {
            padding: 20px;
        }
        
        .close-modal {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            line-height: 1;
        }
        
        .close-modal:hover {
            color: black;
        }
        
        .main-header {
            background-color: #2c3e50;
            color: white;
            padding: 10px 0;
        }
        
        .main-header .container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 20px;
        }
        
        .logo {
            display: flex;
            align-items: center;
        }
        
        .logo i {
            font-size: 1.5rem;
            margin-right: 10px;
        }
        
        .logo h1 {
            font-size: 1.5rem;
            margin: 0;
        }
        
        .main-nav ul {
            display: flex;
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .main-nav li {
            margin-left: 20px;
        }
        
        .main-nav a {
            color: white;
            text-decoration: none;
            transition: opacity 0.3s ease;
        }
        
        .main-nav a:hover {
            opacity: 0.8;
        }
        
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            color: white;
            font-size: 1.5rem;
            cursor: pointer;
        }
        
        .recent-reviews {
            margin-top: 20px;
        }
        
        .review-card {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }
        
        .review-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        
        .review-book {
            font-weight: 600;
        }
        
        .review-date {
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .review-rating {
            margin-bottom: 10px;
            color: #ffc107;
        }
        
        .review-comment {
            margin-bottom: 0;
        }
        
        .profile-tabs {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        
        .tab-button {
            background-color: #f8f9fa;
            border: 1px solid #ced4da;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
        }
        
        .tab-button.active {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .profile-container {
                grid-template-columns: 1fr;
            }
            
            .form-row {
                flex-direction: column;
                gap: 0;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .main-nav {
                display: none;
            }
            
            .main-nav.active {
                display: block;
                position: absolute;
                top: 60px;
                left: 0;
                right: 0;
                background-color: #2c3e50;
                padding: 10px 0;
                z-index: 100;
            }
            
            .main-nav.active ul {
                flex-direction: column;
            }
            
            .main-nav.active li {
                margin: 0;
            }
            
            .main-nav.active a {
                display: block;
                padding: 10px 20px;
            }
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Initialize DAOs
    UserDAO userDAO = new UserDAO();
    BookDAO bookDAO = new BookDAO();
    ReviewDAO reviewDAO = new ReviewDAO();
    
    // Get user reading stats
    Map<String, Integer> readingStats = new HashMap<>();
    try {
        readingStats = bookDAO.getUserReadingStats(user.getUserId());
    } catch (Exception e) {
        // Handle case where method doesn't exist
        readingStats.put("finished", 0);
        readingStats.put("currentlyReading", 0);
        readingStats.put("toRead", 0);
        readingStats.put("bookmarked", 0);
    }
    
    // Get user reviews
    List<Review> userReviews = new ArrayList<>();
    try {
        userReviews = reviewDAO.getReviewsByUser(user.getUserId());
    } catch (Exception e) {
        // Handle exception
        e.printStackTrace();
    }
    
    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    String joinDate = user.getRegistrationDate() != null ? dateFormat.format(user.getRegistrationDate()) : "N/A";
    
    // Get messages from session
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
    %>

    <header class="main-header">
        <div class="container">
            <div class="logo">
                <i class="fas fa-book-open"></i>
                <h1>E-Library Hub</h1>
            </div>
            <nav class="main-nav">
                <ul>
                    <li><a href="../index.jsp">Home</a></li>
                    <li><a href="../browsebook.jsp">Browse Books</a></li>
                    <li><a href="../LogoutServlet">Logout</a></li>
                </ul>
            </nav>
            <button class="mobile-menu-toggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>
    </header>

    <div class="dashboard-container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2>User Dashboard</h2>
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="reading-list.jsp"><i class="fas fa-list"></i> Reading List</a></li>
                <li><a href="bookmarks.jsp"><i class="fas fa-bookmark"></i> Bookmarks</a></li>
                <li><a href="history.jsp"><i class="fas fa-history"></i> History</a></li>
                <li><a href="my-reviews.jsp"><i class="fas fa-star"></i> My Reviews</a></li>
                <li><a href="profile.jsp" class="active"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">My Profile</h1>
            </div>
            
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= successMessage %>
            </div>
            <% } %>
            
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
            </div>
            <% } %>
            
            <div class="profile-container">
                <div class="profile-sidebar">
                    <div class="profile-avatar-container">
                        <img src="<%= user.getProfileImage() != null ? "../" + user.getProfileImage() : "../images/default-avatar.png" %>" alt="Profile Picture" class="profile-avatar">
                        <div class="avatar-overlay" id="changeAvatarOverlay">
                            <i class="fas fa-camera"></i>
                        </div>
                    </div>
                    <h2 class="profile-name"><%= user.getFullName() %></h2>
                    <p class="profile-role"><%= user.getRole().toString() %></p>
                    
                    <div class="profile-stats">
                        <div class="profile-stat">
                            <div class="profile-stat-value"><%= readingStats.getOrDefault("finished", 0) %></div>
                            <div class="profile-stat-label">Books Read</div>
                        </div>
                        <div class="profile-stat">
                            <div class="profile-stat-value"><%= readingStats.getOrDefault("currentlyReading", 0) %></div>
                            <div class="profile-stat-label">Reading</div>
                        </div>
                        <div class="profile-stat">
                            <div class="profile-stat-value"><%= userReviews.size() %></div>
                            <div class="profile-stat-label">Reviews</div>
                        </div>
                        <div class="profile-stat">
                            <div class="profile-stat-value"><%= readingStats.getOrDefault("bookmarked", 0) %></div>
                            <div class="profile-stat-label">Bookmarked</div>
                        </div>
                    </div>
                    
                    <div style="text-align: center;">
                        <p style="margin-bottom: 5px; color: #6c757d;">Member since</p>
                        <p><strong><%= joinDate %></strong></p>
                    </div>
                    
                    <% if (!userReviews.isEmpty()) { %>
                    <div class="recent-reviews">
                        <h3 style="font-size: 1rem; margin-bottom: 10px;">Recent Reviews</h3>
                        <% 
                        int reviewsToShow = Math.min(userReviews.size(), 2);
                        for (int i = 0; i < reviewsToShow; i++) {
                            Review review = userReviews.get(i);
                            SimpleDateFormat reviewDateFormat = new SimpleDateFormat("MMM dd, yyyy");
                            String reviewDate = reviewDateFormat.format(review.getReviewDate());
                        %>
                        <div class="review-card">
                            <div class="review-header">
                                <div class="review-book"><%= review.getBookTitle() %></div>
                                <div class="review-date"><%= reviewDate %></div>
                            </div>
                            <div class="review-rating">
                                <% for (int j = 0; j < 5; j++) { %>
                                    <% if (j < review.getRating()) { %>
                                        <i class="fas fa-star"></i>
                                    <% } else { %>
                                        <i class="far fa-star"></i>
                                    <% } %>
                                <% } %>
                            </div>
                            <p class="review-comment">
                                <%= review.getComment().length() > 100 ? review.getComment().substring(0, 100) + "..." : review.getComment() %>
                            </p>
                        </div>
                        <% } %>
                        <div style="text-align: center; margin-top: 10px;">
                            <a href="my-reviews.jsp" style="color: #007bff; text-decoration: none;">View all reviews</a>
                        </div>
                    </div>
                    <% } %>
                </div>
                
                <div class="profile-main">
                    <div class="profile-tabs">
                        <button class="tab-button active" onclick="openTab(event, 'profile-info')">Profile Information</button>
                        <button class="tab-button" onclick="openTab(event, 'change-password')">Change Password</button>
                        <button class="tab-button" onclick="openTab(event, 'deactivate-account')">Deactivate Account</button>
                    </div>
                    
                    <div id="profile-info" class="tab-content active">
                        <form action="${pageContext.request.contextPath}/UserProfileServlet" method="post" id="profileForm">
                            <input type="hidden" name="action" value="updateProfile">
                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="firstName">First Name</label>
                                    <input type="text" id="firstName" name="firstName" value="<%= user.getFirstName() %>" required class="form-control">
                                </div>
                                
                                <div class="form-group">
                                    <label for="lastName">Last Name</label>
                                    <input type="text" id="lastName" name="lastName" value="<%= user.getLastName() %>" required class="form-control">
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" value="<%= user.getEmail() %>" required class="form-control">
                            </div>
                            
                            <div class="form-group">
                                <label for="bio">Bio</label>
                                <textarea id="bio" name="bio" class="form-control" rows="4"><%= user.getBio() != null ? user.getBio() : "" %></textarea>
                            </div>
                            
                            <div class="form-group">
                                <button type="submit" class="btn-primary">Update Profile</button>
                            </div>
                        </form>
                    </div>
                    
                    <div id="change-password" class="tab-content">
                        <form action="${pageContext.request.contextPath}/UserProfileServlet" method="post" id="passwordForm">
                            <input type="hidden" name="action" value="changePassword">
                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                            
                            <div class="form-group">
                                <label for="currentPassword">Current Password</label>
                                <input type="password" id="currentPassword" name="currentPassword" required class="form-control">
                            </div>
                            
                            <div class="form-group">
                                <label for="newPassword">New Password</label>
                                <input type="password" id="newPassword" name="newPassword" required class="form-control" 
                                       pattern="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$">
                                <small>Password must be at least 8 characters and include letters and numbers</small>
                                <div id="passwordStrength" class="password-strength"></div>
                                <div id="passwordFeedback" class="password-feedback"></div>
                            </div>
                            
                            <div class="form-group">
                                <label for="confirmPassword">Confirm New Password</label>
                                <input type="password" id="confirmPassword" name="confirmPassword" required class="form-control">
                            </div>
                            
                            <div class="form-group">
                                <button type="submit" class="btn-primary" onclick="return validatePasswords()">Change Password</button>
                            </div>
                        </form>
                    </div>
                    
                    <div id="deactivate-account" class="tab-content">
                        <div class="alert alert-danger">
                            <p><strong>Warning:</strong> Deactivating your account will make your profile inaccessible. You can reactivate your account by contacting an administrator.</p>
                        </div>
                        
                        <form action="${pageContext.request.contextPath}/UserDeactivationServlet" method="post" id="deactivateForm">
                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                            
                            <div class="form-group">
                                <label for="deactivatePassword">Enter Your Password</label>
                                <input type="password" id="deactivatePassword" name="password" required class="form-control">
                            </div>
                            
                            <div class="form-group">
                                <label class="checkbox-container">
                                    <input type="checkbox" id="confirmDeactivate" name="confirmDeactivate" value="true" required>
                                    <span class="checkmark"></span>
                                    I understand that deactivating my account will hide my profile and I will need to contact an administrator to reactivate it.
                                </label>
                            </div>
                            
                            <div class="form-group">
                                <button type="submit" class="btn-danger" onclick="return confirmDeactivation()">Deactivate Account</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <!-- Change Avatar Modal -->
    <div id="changeAvatarModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Change Profile Picture</h2>
            </div>
            <div class="modal-body">
                <form action="${pageContext.request.contextPath}/UserProfileServlet" method="post" enctype="multipart/form-data" id="avatarForm">
                    <input type="hidden" name="action" value="updateAvatar">
                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                    
                    <div class="form-group">
                        <label for="avatarFile">Select Image</label>
                        <input type="file" id="avatarFile" name="avatarFile" class="form-control" accept="image/*" required>
                        <small class="form-text text-muted">Maximum file size: 2MB. Recommended size: 300x300 pixels.</small>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn-secondary close-modal-btn">Cancel</button>
                        <button type="submit" class="btn-primary">Upload</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        // Close modals when clicking on X or close button
        document.querySelectorAll('.close-modal, .close-modal-btn').forEach(function(element) {
            element.addEventListener('click', function() {
                document.querySelectorAll('.modal').forEach(function(modal) {
                    modal.style.display = 'none';
                });
                document.body.style.overflow = 'auto';
            });
        });
        
        // Close modals when clicking outside the modal content
        window.addEventListener('click', function(event) {
            document.querySelectorAll('.modal').forEach(function(modal) {
                if (event.target === modal) {
                    modal.style.display = 'none';
                    document.body.style.overflow = 'auto';
                }
            });
        });
        
        // Open modals
        document.getElementById('changeAvatarOverlay').addEventListener('click', function() {
            openModal('changeAvatarModal');
        });
        
        // Password strength checker
        document.getElementById('newPassword').addEventListener('input', function() {
            const password = this.value;
            const strength = checkPasswordStrength(password);
            const strengthBar = document.getElementById('passwordStrength');
            const feedback = document.getElementById('passwordFeedback');
            
            // Update strength bar
            strengthBar.className = 'password-strength';
            if (password.length > 0) {
                strengthBar.classList.add(strength.level);
            }
            
            // Update feedback text
            feedback.textContent = strength.message;
        });
        
        // Password confirmation checker
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = this.value;
            
            if (confirmPassword.length > 0) {
                if (newPassword !== confirmPassword) {
                    this.setCustomValidity('Passwords do not match');
                } else {
                    this.setCustomValidity('');
                }
            }
        });
        
        // Check password strength
        function checkPasswordStrength(password) {
            if (password.length === 0) {
                return { level: '', message: '' };
            }
            
            // Check length
            if (password.length < 8) {
                return { level: 'weak', message: 'Password is too short (minimum 8 characters)' };
            }
            
            // Check complexity
            const hasUpperCase = /[A-Z]/.test(password);
            const hasLowerCase = /[a-z]/.test(password);
            const hasNumbers = /\d/.test(password);
            const hasSpecialChars = /[!@#$%^&*(),.?":{}|<>]/.test(password);
            
            const complexity = [hasUpperCase, hasLowerCase, hasNumbers, hasSpecialChars].filter(Boolean).length;
            
            if (complexity === 4) {
                return { level: 'strong', message: 'Strong password' };
            } else if (complexity >= 2) {
                return { level: 'medium', message: 'Medium strength password. Add special characters for stronger security.' };
            } else {
                return { level: 'weak', message: 'Weak password. Use a mix of uppercase, lowercase, numbers, and special characters.' };
            }
        }
        
        // Form validation
        function validatePasswords() {
            var newPassword = document.getElementById("newPassword").value;
            var confirmPassword = document.getElementById("confirmPassword").value;
            
            if (newPassword !== confirmPassword) {
                alert("New password and confirm password do not match");
                return false;
            }
            
            return true;
        }
        
        function confirmDeactivation() {
            var checkbox = document.getElementById("confirmDeactivate");
            
            if (!checkbox.checked) {
                alert("Please confirm that you understand the consequences of deactivating your account");
                return false;
            }
            
            return confirm("Are you sure you want to deactivate your account? This action requires administrator approval to reverse.");
        }
        
        // Tab functions
        function openTab(evt, tabName) {
            var i, tabContent, tabButtons;
            
            // Hide all tab content
            tabContent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabContent.length; i++) {
                tabContent[i].classList.remove("active");
            }
            
            // Remove "active" class from all tab buttons
            tabButtons = document.getElementsByClassName("tab-button");
            for (i = 0; i < tabButtons.length; i++) {
                tabButtons[i].classList.remove("active");
            }
            
            // Show the current tab and add "active" class to the button
            document.getElementById(tabName).classList.add("active");
            evt.currentTarget.classList.add("active");
        }
        
        // Check if there's an error or success message and show the appropriate tab
        window.onload = function() {
            var errorMessage = "<%= errorMessage != null ? errorMessage : "" %>";
            var successMessage = "<%= successMessage != null ? successMessage : "" %>";
            
            if (errorMessage.includes("password") || successMessage.includes("password")) {
                openTab({currentTarget: document.getElementsByClassName("tab-button")[1]}, "change-password");
            } else if (errorMessage.includes("deactivate") || successMessage.includes("account")) {
                openTab({currentTarget: document.getElementsByClassName("tab-button")[2]}, "deactivate-account");
            }
        };
    </script>
</body>
</html>
