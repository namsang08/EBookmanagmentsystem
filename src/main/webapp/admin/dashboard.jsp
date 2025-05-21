<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, java.util.List, dao.BookDAO, dao.UserDAO, dao.AuthorDAO, mode.Book, mode.Author" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, java.util.Calendar, java.sql.SQLException" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.all.min.js"></script>
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
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .stat-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .stat-card-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        
        .stat-card-icon.books {
            background-color: rgba(74, 109, 167, 0.1);
            color: var(--primary-color);
        }
        
        .stat-card-icon.users {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .stat-card-icon.authors {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .stat-card-icon.downloads {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .stat-card-value {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-card-label {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .stat-card-footer {
            font-size: 0.9rem;
            color: var(--text-light);
        }
        
        .trend-up {
            color: #28a745;
        }
        
        .trend-down {
            color: #dc3545;
        }
        
        .recent-section {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            margin-bottom: 30px;
        }
        
        .recent-section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .recent-section-title {
            font-size: 1.2rem;
        }
        
        .recent-section table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .recent-section th, .recent-section td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        .recent-section th {
            font-weight: 600;
            color: var(--text-light);
        }
        
        .recent-section tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        .status-badge.active, .status-badge.approved {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .status-badge.pending {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .status-badge.inactive, .status-badge.rejected {
            background-color: rgba(108, 117, 125, 0.1);
            color: #6c757d;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .action-btn {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--secondary-color);
            color: var(--text-color);
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .action-btn:hover {
            background-color: var(--primary-color);
            color: white;
        }
        
        .action-btn.view:hover {
            background-color: #17a2b8;
        }
        
        .action-btn.edit:hover {
            background-color: #ffc107;
        }
        
        .action-btn.delete:hover {
            background-color: #dc3545;
        }
        
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .quick-action-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .quick-action-card:hover {
            transform: translateY(-5px);
        }
        
        .quick-action-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin: 0 auto 15px;
            background-color: rgba(74, 109, 167, 0.1);
            color: var(--primary-color);
        }
        
        .quick-action-title {
            font-size: 1.1rem;
            margin-bottom: 10px;
        }
        
        .quick-action-desc {
            font-size: 0.9rem;
            color: var(--text-light);
            margin-bottom: 15px;
        }
        
        /* Modal styles */
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
            background-color: #fefefe;
            margin: 10% auto;
            padding: 20px;
            border-radius: var(--border-radius);
            width: 50%;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            position: relative;
        }
        
        .close-modal {
            position: absolute;
            right: 20px;
            top: 15px;
            font-size: 1.5rem;
            cursor: pointer;
        }
        
        .modal-header {
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .modal-title {
            font-size: 1.3rem;
            margin: 0;
        }
        
        .modal-body {
            margin-bottom: 20px;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .modal-content {
                width: 90%;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in and is an admin
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect("../login.jsp?error=unauthorized");
            return;
        }
        
        // Initialize DAOs
        BookDAO bookDAO = new BookDAO();
        UserDAO userDAO = new UserDAO();
        AuthorDAO authorDAO = new AuthorDAO();
        
        // Get statistics
        int totalBooks = 0;
        int totalUsers = 0;
        int totalAuthors = 0;
        int totalDownloads = 0;
        
        // Get growth percentages
        int bookGrowth = 0;
        int userGrowth = 0;
        int authorGrowth = 0;
        int downloadGrowth = 0;
        
        // Get recent books and users
        List<Book> recentBooks = null;
        List<User> recentUsers = null;
        
        try {
            // Get total counts
            List<Book> allBooks = bookDAO.getAllBooks();
            totalBooks = allBooks.size();
            
            List<User> allUsers = userDAO.getAllUsers();
            totalUsers = allUsers.size();
            
            totalAuthors = authorDAO.getTotalAuthorsCount();
            
            // Calculate total downloads
            for (Book book : allBooks) {
                totalDownloads += book.getDownloads();
            }
            
            // Calculate growth (last month vs previous month)
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MONTH, -1);
            Date oneMonthAgo = cal.getTime();
            
            cal.add(Calendar.MONTH, -1);
            Date twoMonthsAgo = cal.getTime();
            
            int lastMonthBooks = 0;
            int prevMonthBooks = 0;
            int lastMonthUsers = 0;
            int prevMonthUsers = 0;
            int lastMonthAuthors = 0;
            int prevMonthAuthors = 0;
            int lastMonthDownloads = 0;
            int prevMonthDownloads = 0;
            
            for (Book book : allBooks) {
                Date uploadDate = new Date(book.getUploadDate().getTime());
                if (uploadDate.after(oneMonthAgo)) {
                    lastMonthBooks++;
                } else if (uploadDate.after(twoMonthsAgo)) {
                    prevMonthBooks++;
                }
            }
            
            for (User u : allUsers) {
                Date regDate = new Date(u.getRegistrationDate().getTime());
                if (regDate.after(oneMonthAgo)) {
                    lastMonthUsers++;
                    if (u.getRole() == User.Role.AUTHOR) {
                        lastMonthAuthors++;
                    }
                } else if (regDate.after(twoMonthsAgo)) {
                    prevMonthUsers++;
                    if (u.getRole() == User.Role.AUTHOR) {
                        prevMonthAuthors++;
                    }
                }
            }
            
            // Calculate growth percentages
            bookGrowth = prevMonthBooks > 0 ? ((lastMonthBooks - prevMonthBooks) * 100 / prevMonthBooks) : 0;
            userGrowth = prevMonthUsers > 0 ? ((lastMonthUsers - prevMonthUsers) * 100 / prevMonthUsers) : 0;
            authorGrowth = prevMonthAuthors > 0 ? ((lastMonthAuthors - prevMonthAuthors) * 100 / prevMonthAuthors) : 0;
            downloadGrowth = 5; // Placeholder, would need download history to calculate accurately
            
            // Get recent books (5 most recent)
            recentBooks = allBooks;
            java.util.Collections.sort(recentBooks, (b1, b2) -> b2.getUploadDate().compareTo(b1.getUploadDate()));
            if (recentBooks.size() > 5) {
                recentBooks = recentBooks.subList(0, 5);
            }
            
            // Get recent users (5 most recent)
            recentUsers = allUsers;
            java.util.Collections.sort(recentUsers, (u1, u2) -> u2.getRegistrationDate().compareTo(u1.getRegistrationDate()));
            if (recentUsers.size() > 5) {
                recentUsers = recentUsers.subList(0, 5);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // Format date
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
        String currentDate = dateFormat.format(new Date());
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
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="books.jsp"><i class="fas fa-book"></i> Books</a></li>
                <li><a href="users.jsp"><i class="fas fa-users"></i> Users</a></li>
                <li><a href="authors.jsp"><i class="fas fa-user-edit"></i> Authors</a></li>
                <li><a href="categories.jsp"><i class="fas fa-tags"></i> Categories</a></li>
                <li><a href="reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a></li>
                <li><a href="settings.jsp"><i class="fas fa-cog"></i> Settings</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">Admin Dashboard</h1>
                <div class="date">
                    <i class="far fa-calendar-alt"></i> <%= currentDate %>
                </div>
            </div>
            
            <div class="quick-actions">
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3 class="quick-action-title">Manage Books</h3>
                    <p class="quick-action-desc">Review and manage all books</p>
                    <a href="books.jsp" class="btn-primary">Manage</a>
                </div>
                
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="quick-action-title">Manage Users</h3>
                    <p class="quick-action-desc">View and manage user accounts</p>
                    <a href="users.jsp" class="btn-primary">Manage</a>
                </div>
                
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-user-edit"></i>
                    </div>
                    <h3 class="quick-action-title">Manage Authors</h3>
                    <p class="quick-action-desc">Review author accounts</p>
                    <a href="authors.jsp" class="btn-primary">Manage</a>
                </div>
                
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-tags"></i>
                    </div>
                    <h3 class="quick-action-title">Categories</h3>
                    <p class="quick-action-desc">Manage book categories</p>
                    <a href="categories.jsp" class="btn-primary">Manage</a>
                </div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalBooks %></div>
                            <div class="stat-card-label">Total Books</div>
                        </div>
                        <div class="stat-card-icon books">
                            <i class="fas fa-book"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <% if (bookGrowth >= 0) { %>
                            <span class="trend-up"><i class="fas fa-arrow-up"></i> <%= bookGrowth %>%</span>
                        <% } else { %>
                            <span class="trend-down"><i class="fas fa-arrow-down"></i> <%= Math.abs(bookGrowth) %>%</span>
                        <% } %>
                        from last month
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalUsers %></div>
                            <div class="stat-card-label">Total Users</div>
                        </div>
                        <div class="stat-card-icon users">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <% if (userGrowth >= 0) { %>
                            <span class="trend-up"><i class="fas fa-arrow-up"></i> <%= userGrowth %>%</span>
                        <% } else { %>
                            <span class="trend-down"><i class="fas fa-arrow-down"></i> <%= Math.abs(userGrowth) %>%</span>
                        <% } %>
                        from last month
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalAuthors %></div>
                            <div class="stat-card-label">Authors</div>
                        </div>
                        <div class="stat-card-icon authors">
                            <i class="fas fa-user-edit"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <% if (authorGrowth >= 0) { %>
                            <span class="trend-up"><i class="fas fa-arrow-up"></i> <%= authorGrowth %>%</span>
                        <% } else { %>
                            <span class="trend-down"><i class="fas fa-arrow-down"></i> <%= Math.abs(authorGrowth) %>%</span>
                        <% } %>
                        from last month
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalDownloads %></div>
                            <div class="stat-card-label">Downloads</div>
                        </div>
                        <div class="stat-card-icon downloads">
                            <i class="fas fa-download"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <% if (downloadGrowth >= 0) { %>
                            <span class="trend-up"><i class="fas fa-arrow-up"></i> <%= downloadGrowth %>%</span>
                        <% } else { %>
                            <span class="trend-down"><i class="fas fa-arrow-down"></i> <%= Math.abs(downloadGrowth) %>%</span>
                        <% } %>
                        from last month
                    </div>
                </div>
            </div>
            
            <div class="recent-section">
                <div class="recent-section-header">
                    <h2 class="recent-section-title">Recent Books</h2>
                    <a href="books.jsp" class="btn-secondary">View All</a>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Author</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>Date Added</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentBooks != null && !recentBooks.isEmpty()) {
                            for (Book book : recentBooks) {
                                String statusClass = "";
                                if (book.getStatus() == Book.Status.APPROVED) {
                                    statusClass = "approved";
                                } else if (book.getStatus() == Book.Status.PENDING) {
                                    statusClass = "pending";
                                } else {
                                    statusClass = "rejected";
                                }
                        %>
                        <tr>
                            <td><%= book.getTitle() %></td>
                            <td><%= book.getAuthorName() %></td>
                            <td><%= book.getCategoryName() %></td>
                            <td>
                                <span class="status-badge <%= statusClass %>"><%= book.getStatus() %></span>
                            </td>
                            <td><%= dateFormat.format(book.getUploadDate()) %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn view" onclick="viewBook(<%= book.getBookId() %>)">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="action-btn edit" onclick="editBook(<%= book.getBookId() %>)">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="action-btn delete" onclick="confirmDeleteBook(<%= book.getBookId() %>, '<%= book.getTitle() %>')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% 
                            }
                        } else { 
                        %>
                        <tr>
                            <td colspan="6" style="text-align: center;">No books found</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            
            <div class="recent-section">
                <div class="recent-section-header">
                    <h2 class="recent-section-title">Recent Users</h2>
                    <a href="users.jsp" class="btn-secondary">View All</a>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Joined Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentUsers != null && !recentUsers.isEmpty()) {
                            for (User u : recentUsers) {
                        %>
                        <tr>
                            <td><%= u.getFullName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getRole() %></td>
                            <td>
                                <% if (u.isActive()) { %>
                                    <span class="status-badge active">Active</span>
                                <% } else { %>
                                    <span class="status-badge inactive">Inactive</span>
                                <% } %>
                            </td>
                            <td><%= dateFormat.format(u.getRegistrationDate()) %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn view" onclick="viewUser(<%= u.getUserId() %>)">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="action-btn edit" onclick="editUser(<%= u.getUserId() %>)">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="action-btn delete" onclick="confirmDeleteUser(<%= u.getUserId() %>, '<%= u.getFullName() %>')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% 
                            }
                        } else { 
                        %>
                        <tr>
                            <td colspan="6" style="text-align: center;">No users found</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
    
    <!-- View Book Modal -->
    <div id="viewBookModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Book Details</h2>
            </div>
            <div class="modal-body" id="bookDetailsContent">
                <!-- Book details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Close</button>
            </div>
        </div>
    </div>
    
    <!-- View User Modal -->
    <div id="viewUserModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">User Details</h2>
            </div>
            <div class="modal-body" id="userDetailsContent">
                <!-- User details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Close</button>
            </div>
        </div>
    </div>
    
    <!-- Delete Book Modal -->
    <div id="deleteBookModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Delete Book</h2>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this book? This action cannot be undone.</p>
                <p><strong>Book Title: </strong><span id="deleteBookTitle"></span></p>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Cancel</button>
                <button class="btn-danger" id="confirmDeleteBookBtn">Delete</button>
            </div>
        </div>
    </div>
    
    <!-- Delete User Modal -->
    <div id="deleteUserModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Delete User</h2>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this user? This action cannot be undone.</p>
                <p><strong>User Name: </strong><span id="deleteUserName"></span></p>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Cancel</button>
                <button class="btn-danger" id="confirmDeleteUserBtn">Delete</button>
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
        
        // Book actions
        function viewBook(bookId) {
            fetch('../AdminBookServlet?action=getBookDetails&id=' + bookId)
                .then(response => response.text())
                .then(data => {
                    try {
                        const book = JSON.parse(data);
                        
                        // Format dates
                        const uploadDate = new Date(book.uploadDate);
                        const formattedUploadDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                        }).format(uploadDate);
                        
                        const publicationDate = new Date(book.publicationDate);
                        const formattedPublicationDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                        }).format(publicationDate);
                        
                        // Create HTML for book details
                        let statusClass = '';
                        if (book.status === 'APPROVED') {
                            statusClass = 'approved';
                        } else if (book.status === 'PENDING') {
                            statusClass = 'pending';
                        } else {
                            statusClass = 'rejected';
                        }
                        
                        const bookDetailsHTML = '<div style="display: flex; gap: 20px; margin-bottom: 20px;">' +
                            '<div style="flex: 0 0 150px;">' +
                            '<img src="' + book.coverImagePath + '" alt="' + book.title + '" style="width: 100%; border-radius: 5px;">' +
                            '</div>' +
                            '<div style="flex: 1;">' +
                            '<h3 style="margin-top: 0;">' + book.title + '</h3>' +
                            '<p><strong>Author:</strong> ' + book.authorName + '</p>' +
                            '<p><strong>Category:</strong> ' + book.categoryName + '</p>' +
                            '<p><strong>Status:</strong> <span class="status-badge ' + statusClass + '">' + book.status + '</span></p>' +
                            '<p><strong>Publication Date:</strong> ' + formattedPublicationDate + '</p>' +
                            '<p><strong>Upload Date:</strong> ' + formattedUploadDate + '</p>' +
                            '<p><strong>Language:</strong> ' + book.language + '</p>' +
                            '<p><strong>Pages:</strong> ' + book.pages + '</p>' +
                            '</div>' +
                            '</div>' +
                            '<div style="margin-bottom: 20px;">' +
                            '<h4>Description</h4>' +
                            '<p>' + book.description + '</p>' +
                            '</div>' +
                            '<div style="display: flex; gap: 20px;">' +
                            '<div style="flex: 1;">' +
                            '<h4>Statistics</h4>' +
                            '<p><strong>Views:</strong> ' + book.views + '</p>' +
                            '<p><strong>Downloads:</strong> ' + book.downloads + '</p>' +
                            '<p><strong>Rating:</strong> ' + (book.rating > 0 ? book.rating.toFixed(1) + ' <i class="fas fa-star" style="color: gold;"></i>' : 'N/A') + '</p>' +
                            '</div>' +
                            '<div style="flex: 1;">' +
                            '<h4>File Information</h4>' +
                            '<p><strong>File Path:</strong> ' + book.filePath + '</p>' +
                            '<a href="../DownloadServlet?id=' + book.bookId + '" class="btn-primary" style="display: inline-block; margin-top: 10px;">Download</a>' +
                            '</div>' +
                            '</div>';
                        
                        document.getElementById('bookDetailsContent').innerHTML = bookDetailsHTML;
                        openModal('viewBookModal');
                    } catch (e) {
                        console.error('Error parsing book details:', e);
                        Swal.fire({
                            title: 'Error!',
                            text: 'Failed to load book details.',
                            icon: 'error'
                        });
                    }
                })
                .catch(error => {
                    console.error('Error fetching book details:', error);
                    Swal.fire({
                        title: 'Error!',
                        text: 'Failed to load book details.',
                        icon: 'error'
                    });
                });
        }
        
        function editBook(bookId) {
            window.location.href = "edit-book.jsp?id=" + bookId;
        }
        
        function confirmDeleteBook(bookId, bookTitle) {
            document.getElementById('deleteBookTitle').textContent = bookTitle;
            document.getElementById('confirmDeleteBookBtn').onclick = function() {
                deleteBook(bookId);
            };
            openModal('deleteBookModal');
        }
        
        function deleteBook(bookId) {
            fetch('../AdminBookServlet?action=delete&id=' + bookId, {
                method: 'POST'
            })
            .then(response => response.text())
            .then(data => {
                try {
                    const result = JSON.parse(data);
                    if (result.success) {
                        Swal.fire({
                            title: 'Deleted!',
                            text: 'Book has been deleted successfully.',
                            icon: 'success'
                        }).then(() => {
                            window.location.reload();
                        });
                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: result.message || 'Failed to delete book.',
                            icon: 'error'
                        });
                    }
                } catch (e) {
                    console.error('Error parsing response:', e);
                    Swal.fire({
                        title: 'Error!',
                        text: 'An unexpected error occurred.',
                        icon: 'error'
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while deleting the book.',
                    icon: 'error'
                });
            });
            
            closeModal('deleteBookModal');
        }
        
        // User actions
        function viewUser(userId) {
            fetch('../AdminUserServlet?action=getUserDetails&id=' + userId)
                .then(response => response.text())
                .then(data => {
                    try {
                        const user = JSON.parse(data);
                        
                        // Format dates
                        const registrationDate = new Date(user.registrationDate);
                        const formattedRegistrationDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                        }).format(registrationDate);
                        
                        let lastLoginDate = 'Never';
                        if (user.lastLogin) {
                            const lastLogin = new Date(user.lastLogin);
                            lastLoginDate = new Intl.DateTimeFormat('en-US', {
                                year: 'numeric',
                                month: 'long',
                                day: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit'
                            }).format(lastLogin);
                        }
                        
                        // Create HTML for user details
                        let userDetailsHTML = '<div style="display: flex; gap: 20px; margin-bottom: 20px;">' +
                            '<div style="flex: 0 0 150px;">' +
                            '<img src="' + (user.profileImage || '../images/default-profile.png') + '" alt="' + user.firstName + ' ' + user.lastName + '" style="width: 100%; border-radius: 5px;">' +
                            '</div>' +
                            '<div style="flex: 1;">' +
                            '<h3 style="margin-top: 0;">' + user.firstName + ' ' + user.lastName + '</h3>' +
                            '<p><strong>Email:</strong> ' + user.email + '</p>' +
                            '<p><strong>Role:</strong> ' + user.role + '</p>' +
                            '<p><strong>Status:</strong> ' +
                            '<span class="status-badge ' + (user.active ? 'active' : 'inactive') + '">' +
                            (user.active ? 'Active' : 'Inactive') +
                            '</span>' +
                            '</p>' +
                            '<p><strong>Registration Date:</strong> ' + formattedRegistrationDate + '</p>' +
                            '<p><strong>Last Login:</strong> ' + lastLoginDate + '</p>' +
                            '</div>' +
                            '</div>';

                        // Add bio section if available
                        if (user.bio) {
                            userDetailsHTML += '<div style="margin-bottom: 20px;">' +
                                '<h4>Bio</h4>' +
                                '<p>' + user.bio + '</p>' +
                                '</div>';
                        }

                        // Add author statistics if user is an author
                        if (user.role === 'AUTHOR') {
                            userDetailsHTML += '<div style="margin-top: 20px;">' +
                                '<h4>Author Statistics</h4>' +
                                '<p><strong>Total Books:</strong> <span id="authorTotalBooks">Loading...</span></p>' +
                                '<p><strong>Total Downloads:</strong> <span id="authorTotalDownloads">Loading...</span></p>' +
                                '<p><strong>Average Rating:</strong> <span id="authorAvgRating">Loading...</span></p>' +
                                '<button class="btn-primary" onclick="window.location.href=\'authors.jsp?id=' + user.userId + '\'">View Author Details</button>' +
                                '</div>';
                        }
                        
                        document.getElementById('userDetailsContent').innerHTML = userDetailsHTML;
                        openModal('viewUserModal');
                        
                        // If user is an author, fetch additional statistics
                        if (user.role === 'AUTHOR') {
                            fetch('../AdminAuthorServlet?action=getAuthorStats&id=' + userId)
                                .then(response => response.text())
                                .then(statsData => {
                                    try {
                                        const stats = JSON.parse(statsData);
                                        document.getElementById('authorTotalBooks').textContent = stats.totalBooks;
                                        document.getElementById('authorTotalDownloads').textContent = stats.totalDownloads;
                                        document.getElementById('authorAvgRating').textContent = 
                                            stats.averageRating > 0 ? 
                                            stats.averageRating.toFixed(1) + ' <i class="fas fa-star" style="color: gold;"></i>' : 
                                            'N/A';
                                    } catch (e) {
                                        console.error('Error parsing author stats:', e);
                                    }
                                })
                                .catch(error => {
                                    console.error('Error fetching author stats:', error);
                                });
                        }
                    } catch (e) {
                        console.error('Error parsing user details:', e);
                        Swal.fire({
                            title: 'Error!',
                            text: 'Failed to load user details.',
                            icon: 'error'
                        });
                    }
                })
                .catch(error => {
                    console.error('Error fetching user details:', error);
                    Swal.fire({
                        title: 'Error!',
                        text: 'Failed to load user details.',
                        icon: 'error'
                    });
                });
        }
        
        function editUser(userId) {
            window.location.href = "edit-user.jsp?id=" + userId;
        }
        
        function confirmDeleteUser(userId, userName) {
            document.getElementById('deleteUserName').textContent = userName;
            document.getElementById('confirmDeleteUserBtn').onclick = function() {
                deleteUser(userId);
            };
            openModal('deleteUserModal');
        }
        
        function deleteUser(userId) {
            fetch('../AdminUserServlet?action=delete&id=' + userId, {
                method: 'POST'
            })
            .then(response => response.text())
            .then(data => {
                try {
                    const result = JSON.parse(data);
                    if (result.success) {
                        Swal.fire({
                            title: 'Deleted!',
                            text: 'User has been deleted successfully.',
                            icon: 'success'
                        }).then(() => {
                            window.location.reload();
                        });
                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: result.message || 'Failed to delete user.',
                            icon: 'error'
                        });
                    }
                } catch (e) {
                    console.error('Error parsing response:', e);
                    Swal.fire({
                        title: 'Error!',
                        text: 'An unexpected error occurred.',
                        icon: 'error'
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while deleting the user.',
                    icon: 'error'
                });
            });
            
            closeModal('deleteUserModal');
        }
    </script>
</body>
</html>
