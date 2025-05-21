<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, java.util.List, dao.UserDAO, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/admin-styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.all.min.js"></script>
    <style>
        .users-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
        }
        
        .stat-card .icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            font-size: 1.5rem;
        }
        
        .stat-card .icon.total {
            background-color: rgba(23, 162, 184, 0.1);
            color: #17a2b8;
        }
        
        .stat-card .icon.admin {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .stat-card .icon.author {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .stat-card .icon.user {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .stat-card .content h3 {
            font-size: 1.8rem;
            margin: 0;
            font-weight: 600;
        }
        
        .stat-card .content p {
            margin: 5px 0 0;
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .search-filter-container {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 20px;
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: var(--border-radius);
        }
        
        .search-box {
            flex: 1;
            min-width: 200px;
            position: relative;
        }
        
        .search-box input {
            width: 100%;
            padding: 10px 15px 10px 40px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
        }
        
        .search-box i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-light);
        }
        
        .filter-dropdown select {
            padding: 10px 15px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            background-color: white;
            min-width: 150px;
        }
        
        .users-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .users-table th, .users-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        .users-table th {
            font-weight: 600;
            color: var(--text-light);
            background-color: #f8f9fa;
        }
        
        .users-table tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        .status-badge.active {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .status-badge.inactive {
            background-color: rgba(108, 117, 125, 0.1);
            color: #6c757d;
        }
        
        .role-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .role-badge.admin {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .role-badge.author {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .role-badge.user {
            background-color: rgba(23, 162, 184, 0.1);
            color: #17a2b8;
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
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-light);
        }
        
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.3;
        }
        
        .empty-state p {
            font-size: 1.1rem;
            margin-bottom: 20px;
        }
        
        @media (max-width: 992px) {
            .stats-cards {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .search-filter-container {
                flex-direction: column;
            }
            
            .search-box, .filter-dropdown {
                width: 100%;
            }
            
            .users-table {
                display: block;
                overflow-x: auto;
            }
        }
        
        @media (max-width: 576px) {
            .stats-cards {
                grid-template-columns: 1fr;
            }
            
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
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
        
        // Get users from DAO
        UserDAO userDAO = new UserDAO();
        List<User> allUsers = userDAO.getAllUsers();
        
        // Count users by role
        int totalUsers = 0;
        int adminCount = 0;
        int authorCount = 0;
        int userCount = 0;
        
        if (allUsers != null) {
            totalUsers = allUsers.size();
            for (User u : allUsers) {
                if (u.getRole() == User.Role.ADMIN) {
                    adminCount++;
                } else if (u.getRole() == User.Role.AUTHOR) {
                    authorCount++;
                } else if (u.getRole() == User.Role.USER) {
                    userCount++;
                }
            }
        }
        
        // Date formatter
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
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
                <h1 class="page-title">Manage Users</h1>
                <a href="add-user.jsp" class="btn-primary"><i class="fas fa-plus"></i> Add New User</a>
            </div>
            
            <!-- Statistics Cards -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="icon total">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="content">
                        <h3><%= totalUsers %></h3>
                        <p>Total Users</p>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="icon admin">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="content">
                        <h3><%= adminCount %></h3>
                        <p>Administrators</p>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="icon author">
                        <i class="fas fa-user-edit"></i>
                    </div>
                    <div class="content">
                        <h3><%= authorCount %></h3>
                        <p>Authors</p>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="icon user">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="content">
                        <h3><%= userCount %></h3>
                        <p>Regular Users</p>
                    </div>
                </div>
            </div>
            
            <div class="users-container">
                <div class="search-filter-container">
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Search by name or email...">
                    </div>
                    <div class="filter-dropdown">
                        <select id="roleFilter">
                            <option value="all">All Roles</option>
                            <option value="ADMIN">Admin</option>
                            <option value="AUTHOR">Author</option>
                            <option value="USER">User</option>
                        </select>
                    </div>
                    <div class="filter-dropdown">
                        <select id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                    <button class="btn-primary" id="applyFilters">
                        <i class="fas fa-filter"></i> Apply Filters
                    </button>
                </div>
                
                <% if (allUsers != null && !allUsers.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="users-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Joined Date</th>
                                <th>Last Login</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="usersTableBody">
                            <% for (User u : allUsers) {
                                if (u.getUserId() == user.getUserId()) continue; // Skip current admin
                            %>
                            <tr>
                                <td><%= u.getFirstName() + " " + u.getLastName() %></td>
                                <td><%= u.getEmail() %></td>
                                <td>
                                    <% if (u.getRole() == User.Role.ADMIN) { %>
                                        <span class="role-badge admin">Admin</span>
                                    <% } else if (u.getRole() == User.Role.AUTHOR) { %>
                                        <span class="role-badge author">Author</span>
                                    <% } else { %>
                                        <span class="role-badge user">User</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (u.isActive()) { %>
                                        <span class="status-badge active">Active</span>
                                    <% } else { %>
                                        <span class="status-badge inactive">Inactive</span>
                                    <% } %>
                                </td>
                                <td><%= u.getRegistrationDate() != null ? dateFormat.format(u.getRegistrationDate()) : "N/A" %></td>
                                <td><%= u.getLastLogin() != null ? dateFormat.format(u.getLastLogin()) : "Never" %></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="action-btn view" onclick="viewUser(<%= u.getUserId() %>)" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <button class="action-btn edit" onclick="editUser(<%= u.getUserId() %>)" title="Edit User">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="action-btn delete" onclick="confirmDeleteUser(<%= u.getUserId() %>, '<%= u.getFirstName() + " " + u.getLastName() %>')" title="Delete User">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="empty-state">
                    <i class="fas fa-users"></i>
                    <p>No users found</p>
                    <a href="add-user.jsp" class="btn-primary">Add New User</a>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Apply filters
        document.getElementById('applyFilters').addEventListener('click', function() {
            filterUsers();
        });
        
        // Search on enter key
        document.getElementById('searchInput').addEventListener('keyup', function(event) {
            if (event.key === 'Enter') {
                filterUsers();
            }
        });
        
        // Filter users based on search input and dropdown selections
        function filterUsers() {
            const searchQuery = document.getElementById('searchInput').value.toLowerCase();
            const roleFilter = document.getElementById('roleFilter').value;
            const statusFilter = document.getElementById('statusFilter').value;
            
            const rows = document.getElementById('usersTableBody').getElementsByTagName('tr');
            let visibleCount = 0;
            
            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                const nameCell = row.cells[0];
                const emailCell = row.cells[1];
                const roleCell = row.cells[2];
                const statusCell = row.cells[3];
                
                if (!nameCell) continue; // Skip if row doesn't have cells
                
                const name = nameCell.textContent.toLowerCase();
                const email = emailCell.textContent.toLowerCase();
                const role = roleCell.textContent.toLowerCase();
                const status = statusCell.textContent.toLowerCase();
                
                const matchesSearch = name.includes(searchQuery) || email.includes(searchQuery);
                const matchesRole = roleFilter === 'all' || role.includes(roleFilter.toLowerCase());
                const matchesStatus = statusFilter === 'all' || status.includes(statusFilter.toLowerCase());
                
                if (matchesSearch && matchesRole && matchesStatus) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            }
            
            // Show empty state message if no results
            const tableContainer = document.querySelector('.table-responsive');
            const emptyState = document.querySelector('.empty-state');
            
            if (visibleCount === 0 && tableContainer) {
                if (!emptyState) {
                    const newEmptyState = document.createElement('div');
                    newEmptyState.className = 'empty-state';
                    newEmptyState.innerHTML = `
                        <i class="fas fa-search"></i>
                        <p>No users match your search criteria</p>
                        <button class="btn-secondary" onclick="resetFilters()">Reset Filters</button>
                    `;
                    tableContainer.style.display = 'none';
                    document.querySelector('.users-container').appendChild(newEmptyState);
                }
            } else {
                if (tableContainer) tableContainer.style.display = 'block';
                const dynamicEmptyState = document.querySelector('.empty-state:not(:first-child)');
                if (dynamicEmptyState) dynamicEmptyState.remove();
            }
        }
        
        // Reset all filters
        function resetFilters() {
            document.getElementById('searchInput').value = '';
            document.getElementById('roleFilter').value = 'all';
            document.getElementById('statusFilter').value = 'all';
            filterUsers();
        }
        
        // User actions
        function viewUser(userId) {
            window.location.href = "user-details.jsp?id=" + userId;
        }
        
        function editUser(userId) {
            window.location.href = "edit-user.jsp?id=" + userId;
        }
        
        function confirmDeleteUser(userId, userName) {
            Swal.fire({
                title: 'Delete User',
                html: 'Are you sure you want to delete <strong>' + userName + '</strong>?<br><small>This action cannot be undone.</small>',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    deleteUser(userId);
                }
            });
        }
        
        function deleteUser(userId) {
            // Show loading state
            Swal.fire({
                title: 'Deleting...',
                text: 'Please wait while we delete the user.',
                allowOutsideClick: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });
            
            fetch('../AdminUserServlet?action=delete&id=' + userId, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => {
                // Try to parse as JSON, but handle if it's not JSON
                let data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    // If not JSON, create a simple object with the text as message
                    data = { 
                        success: text.includes('success') || text.includes('deleted'), 
                        message: text 
                    };
                }
                
                if (data.success) {
                    Swal.fire({
                        title: 'Deleted!',
                        text: data.message || 'User has been deleted successfully.',
                        icon: 'success'
                    }).then(() => {
                        window.location.reload();
                    });
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: data.message || 'An error occurred while deleting the user.',
                        icon: 'error'
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while deleting the user: ' + error.message,
                    icon: 'error'
                });
            });
        }
    </script>
</body>
</html>
