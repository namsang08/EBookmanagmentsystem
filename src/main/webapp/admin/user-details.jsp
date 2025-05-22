<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, dao.UserDAO, dao.BookDAO, mode.Book, java.util.List, java.util.Map, java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Details - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.all.min.js"></script>
    <style>
        /* Styles remain the same */
    </style>
</head>
<body>
    <%
        // Check if user is logged in and is an admin
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !currentUser.getRole().equals("ADMIN")) {
            response.sendRedirect("../login.jsp?error=unauthorized");
            return;
        }
        
        // Get user ID from request parameter
        int userId = 0;
        try {
            userId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect("users.jsp?error=invalid_id");
            return;
        }
        
        // Get user details
        UserDAO userDAO = new UserDAO();
        BookDAO bookDAO = new BookDAO();
        User user = null;
        List<Map<String, Object>> userActivity = null;
        List<Book> userBooks = null;
        List<Map<String, Object>> userReviews = null;
        Map<String, Object> userStats = null;

        try {
            user = userDAO.findById(userId);
            if (user == null) {
                response.sendRedirect("users.jsp?error=user_not_found");
                return;
            }
            
            // Get user statistics
            userStats = userDAO.getUserStatistics(userId);
            
            // Get user's activity
            try {
                userActivity = userDAO.getUserActivity(userId, 10);
            } catch (Exception e) {
                e.printStackTrace();
                // Continue without activity data
            }
            
            // Get user's books if they are an author
            if (user.getRole().equals("AUTHOR")) {
                try {
                    userBooks = bookDAO.getBooksByAuthor(userId);
                } catch (Exception e) {
                    e.printStackTrace();
                    // Continue without books data
                }
            }
            
            // Get user's reviews
            try {
                userReviews = userDAO.getUserReviews(userId, 10);
            } catch (Exception e) {
                e.printStackTrace();
                // Continue without reviews data
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("users.jsp?error=database_error");
            return;
        }
        
        // Format dates
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("MMM dd, yyyy 'at' h:mm a");
        String registrationDate = dateFormat.format(user.getRegistrationDate());
        
        String lastLoginDate = "Never";
        if (user.getLastLogin() != null) {
            lastLoginDate = dateFormat.format(user.getLastLogin());
        }
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
                <h2>Admin Dashboard</h2>
                <p>Welcome, <%= currentUser.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="books.jsp"><i class="fas fa-book"></i> Books</a></li>
                <li><a href="users.jsp" class="active"><i class="fas fa-users"></i> Users</a></li>
                <li><a href="authors.jsp"><i class="fas fa-user-edit"></i> Authors</a></li>
                <li><a href="categories.jsp"><i class="fas fa-tags"></i> Categories</a></li>
                <li><a href="reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a></li>
                <li><a href="settings.jsp"><i class="fas fa-cog"></i> Settings</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="page-header">
                <h1 class="page-title">User Details</h1>
                <div>
                    <a href="users.jsp" class="btn-secondary"><i class="fas fa-arrow-left"></i> Back to Users</a>
                </div>
            </div>
            
            <div class="user-details-container">
                <div class="user-header">
                    <div class="user-avatar">
                        <img src="<%= user.getProfileImage() != null ? user.getProfileImage() : "../images/default-profile.png" %>" alt="<%= user.getFirstName() + " " + user.getLastName() %>">
                    </div>
                    <div class="user-info">
                        <h1 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h1>
                        <div class="user-meta">
                            <p><strong>Email:</strong> <%= user.getEmail() %></p>
                            <p><strong>Role:</strong> <%= user.getRole() %></p>
                            <p><strong>Registration Date:</strong> <%= registrationDate %></p>
                            <p><strong>Last Login:</strong> <%= lastLoginDate %></p>
                            <p><strong>Status:</strong> 
                                <% if (user.isActive()) { %>
                                    <span class="status-badge active">Active</span>
                                <% } else { %>
                                    <span class="status-badge inactive">Inactive</span>
                                <% } %>
                            </p>
                        </div>
                        <div class="user-actions">
                            <a href="edit-user.jsp?id=<%= user.getUserId() %>" class="btn-secondary"><i class="fas fa-edit"></i> Edit</a>
                            <% if (user.isActive()) { %>
                                <button class="btn-warning" onclick="toggleUserStatus(<%= user.getUserId() %>, false)"><i class="fas fa-ban"></i> Deactivate</button>
                            <% } else { %>
                                <button class="btn-success" onclick="toggleUserStatus(<%= user.getUserId() %>, true)"><i class="fas fa-check"></i> Activate</button>
                            <% } %>
                            <button class="btn-danger" onclick="confirmDeleteUser(<%= user.getUserId() %>, '<%= user.getFirstName() + " " + user.getLastName() %>')"><i class="fas fa-trash"></i> Delete</button>
                        </div>
                    </div>
                </div>
                
                <% if (user.getBio() != null && !user.getBio().isEmpty()) { %>
                <div class="user-bio">
                    <h3>Bio</h3>
                    <p><%= user.getBio() %></p>
                </div>
                <% } %>
                
                <div class="user-stats">
                    <div class="stat-card">
                        <div class="stat-value"><%= userStats != null ? userStats.get("downloadsCount") : 0 %></div>
                        <div class="stat-label">Downloads</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= userStats != null ? userStats.get("reviewsCount") : 0 %></div>
                        <div class="stat-label">Reviews</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= userStats != null ? userStats.get("bookmarksCount") : 0 %></div>
                        <div class="stat-label">Bookmarks</div>
                    </div>
                    <% if (user.getRole().equals("AUTHOR")) { %>
                    <div class="stat-card">
                        <div class="stat-value"><%= userStats != null ? userStats.get("booksPublished") : 0 %></div>
                        <div class="stat-label">Books Published</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value">
                            <% 
                                double avgRating = userStats != null ? (Double)userStats.get("averageRating") : 0.0;
                                if (avgRating > 0) {
                                    out.print(String.format("%.1f", avgRating));
                            %>
                                <i class="fas fa-star" style="color: gold;"></i>
                            <% } else { %>
                                N/A
                            <% } %>
                        </div>
                        <div class="stat-label">Average Rating</div>
                    </div>
                    <% } %>
                </div>
                
                <div class="user-tabs">
                    <div class="user-tab active" data-tab="activity">Activity</div>
                    <% if (user.getRole().equals("AUTHOR")) { %>
                    <div class="user-tab" data-tab="books">Books</div>
                    <% } %>
                    <div class="user-tab" data-tab="reviews">Reviews</div>
                    <div class="user-tab" data-tab="reading">Reading List</div>
                    <div class="user-tab" data-tab="bookmarks">Bookmarks</div>
                </div>
                
                <!-- Tab content sections remain the same -->
            </div>
        </main>
    </div>

    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Tabs functionality
        document.querySelectorAll('.user-tab').forEach(tab => {
            tab.addEventListener('click', function() {
                // Remove active class from all tabs and content
                document.querySelectorAll('.user-tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                
                // Add active class to clicked tab and corresponding content
                this.classList.add('active');
                document.getElementById(this.dataset.tab + '-tab').classList.add('active');
            });
        });
        
        // User actions
        function toggleUserStatus(userId, isActive) {
            const action = isActive ? 'activate' : 'deactivate';
            const confirmTitle = isActive ? 'Activate User' : 'Deactivate User';
            const confirmText = `Are you sure you want to ${action} this user?`;
            const confirmButtonColor = isActive ? '#28a745' : '#ffc107';
            const confirmButtonText = `Yes, ${action}!`;
            
            Swal.fire({
                title: confirmTitle,
                text: confirmText,
                icon: isActive ? 'question' : 'warning',
                showCancelButton: true,
                confirmButtonColor: confirmButtonColor,
                cancelButtonColor: '#6c757d',
                confirmButtonText: confirmButtonText
            }).then((result) => {
                if (result.isConfirmed) {
                    showLoading();
                    fetch('../admin/users', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: `action=toggleStatus&id=${userId}&active=${isActive}`
                    })
                    .then(response => response.json())
                    .then(data => {
                        hideLoading();
                        if (data.success) {
                            Swal.fire({
                                title: `${isActive ? 'Activated' : 'Deactivated'}!`,
                                text: `User has been successfully ${isActive ? 'activated' : 'deactivated'}.`,
                                icon: 'success'
                            }).then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire({
                                title: 'Error!',
                                text: data.message || `Failed to ${action} user.`,
                                icon: 'error'
                            });
                        }
                    })
                    .catch(error => {
                        hideLoading();
                        console.error('Error:', error);
                        Swal.fire({
                            title: 'Error!',
                            text: `An error occurred while ${action}ing the user.`,
                            icon: 'error'
                        });
                    });
                }
            });
        }
        
        function confirmDeleteUser(userId, userName) {
            Swal.fire({
                title: 'Delete User',
                html: `Are you sure you want to delete <strong>${userName}</strong>?<br><small>This action cannot be undone.</small>`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    showLoading();
                    fetch('../admin/users', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: `action=delete&id=${userId}`
                    })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Network response was not ok: ' + response.status);
                        }
                        return response.text();
                    })
                    .then(text => {
                        hideLoading();
                        
                        // Try to parse as JSON, but handle if it's not JSON
                        let data;
                        try {
                            data = JSON.parse(text);
                        } catch (e) {
                            console.error('Failed to parse JSON response:', text);
                            // If not JSON, create a simple object with the text as message
                            data = { 
                                success: text.includes('success') || text.includes('deleted'), 
                                message: text 
                            };
                        }
                        
                        if (data.success) {
                            Swal.fire({
                                title: 'Deleted!',
                                text: data.message || 'User has been successfully deleted.',
                                icon: 'success'
                            }).then(() => {
                                window.location.href = 'users.jsp';
                            });
                        } else {
                            Swal.fire({
                                title: 'Error!',
                                text: data.message || 'Failed to delete user.',
                                icon: 'error'
                            });
                        }
                    })
                    .catch(error => {
                        hideLoading();
                        console.error('Error:', error);
                        Swal.fire({
                            title: 'Error!',
                            text: 'An error occurred while deleting the user: ' + error.message,
                            icon: 'error'
                        });
                    });
                }
            });
        }
        
        function deleteReview(reviewId) {
            Swal.fire({
                title: 'Delete Review',
                text: 'Are you sure you want to delete this review?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    showLoading();
                    fetch('../AdminReviewServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: `action=delete&id=${reviewId}`
                    })
                    .then(response => response.json())
                    .then(data => {
                        hideLoading();
                        if (data.success) {
                            Swal.fire({
                                title: 'Deleted!',
                                text: 'Review has been successfully deleted.',
                                icon: 'success'
                            }).then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire({
                                title: 'Error!',
                                text: data.message || 'Failed to delete review.',
                                icon: 'error'
                            });
                        }
                    })
                    .catch(error => {
                        hideLoading();
                        console.error('Error:', error);
                        Swal.fire({
                            title: 'Error!',
                            text: 'An error occurred while deleting the review.',
                            icon: 'error'
                        });
                    });
                }
            });
        }

        // Loading indicator functions
        function showLoading() {
            document.getElementById('loadingOverlay').classList.add('active');
        }

        function hideLoading() {
            document.getElementById('loadingOverlay').classList.remove('active');
        }
    </script>
</body>
</html>
