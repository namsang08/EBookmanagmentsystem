<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, java.util.List, dao.BookDAO, dao.UserDAO, dao.AuthorDAO, dao.CategoryDAO, dao.ReviewDAO, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Analytics - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/admin-styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .reports-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .report-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .report-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .report-card-title {
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .report-card-body {
            height: 300px;
        }
        
        .filter-dropdown select {
            padding: 5px 10px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            background-color: white;
        }
        
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 15px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        
        .stat-icon {
            font-size: 2rem;
            margin-bottom: 10px;
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        
        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 0.9rem;
            color: #6c757d;
        }
        
        .icon-books { background-color: rgba(13, 110, 253, 0.1); color: #0d6efd; }
        .icon-users { background-color: rgba(25, 135, 84, 0.1); color: #198754; }
        .icon-downloads { background-color: rgba(220, 53, 69, 0.1); color: #dc3545; }
        .icon-views { background-color: rgba(255, 193, 7, 0.1); color: #ffc107; }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .data-table th, .data-table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
        }
        
        .data-table th {
            background-color: #f8f9fa;
            font-weight: 600;
        }
        
        .data-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .export-btn {
            background-color: #198754;
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 0.9rem;
        }
        
        .export-btn:hover {
            background-color: #157347;
        }
        
        @media (max-width: 992px) {
            .reports-container {
                grid-template-columns: 1fr;
            }
            
            .report-card-body {
                height: 250px;
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
        
        // Get DAOs
        BookDAO bookDAO = new BookDAO();
        UserDAO userDAO = new UserDAO();
        AuthorDAO authorDAO = new AuthorDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        ReviewDAO reviewDAO = new ReviewDAO();
        
        // Date formatter
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
        
        // Get statistics
        int totalBooks = 0;
        int totalUsers = 0;
        int totalAuthors = 0;
        int totalDownloads = 0;
        
        try {
            List<User> allUsers = userDAO.getAllUsers();
            totalUsers = allUsers.size();
            
            totalAuthors = authorDAO.getTotalAuthorsCount();
            
            // Count total books and downloads
            List<mode.Book> allBooks = bookDAO.getAllBooks();
            totalBooks = allBooks.size();
            
            for (mode.Book book : allBooks) {
                totalDownloads += book.getDownloads();
            }
        } catch (Exception e) {
            e.printStackTrace();
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
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="books.jsp"><i class="fas fa-book"></i> Books</a></li>
                <li><a href="users.jsp"><i class="fas fa-users"></i> Users</a></li>
                <li><a href="authors.jsp"><i class="fas fa-user-edit"></i> Authors</a></li>
                <li><a href="categories.jsp"><i class="fas fa-tags"></i> Categories</a></li>
                <li><a href="reports.jsp" class="active"><i class="fas fa-chart-bar"></i> Reports</a></li>
                <li><a href="settings.jsp"><i class="fas fa-cog"></i> Settings</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="page-header">
                <h1 class="page-title">Reports & Analytics</h1>
                <div class="filter-dropdown">
                    <select id="timeRangeFilter" onchange="updateCharts()">
                        <option value="7">Last 7 Days</option>
                        <option value="30" selected>Last 30 Days</option>
                        <option value="90">Last 3 Months</option>
                        <option value="365">Last Year</option>
                        <option value="all">All Time</option>
                    </select>
                </div>
            </div>
            
            <!-- Statistics Overview -->
            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-icon icon-books">
                        <i class="fas fa-book"></i>
                    </div>
                    <div class="stat-value"><%= totalBooks %></div>
                    <div class="stat-label">Total Books</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon icon-users">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-value"><%= totalUsers %></div>
                    <div class="stat-label">Total Users</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon icon-users">
                        <i class="fas fa-user-edit"></i>
                    </div>
                    <div class="stat-value"><%= totalAuthors %></div>
                    <div class="stat-label">Total Authors</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon icon-downloads">
                        <i class="fas fa-download"></i>
                    </div>
                    <div class="stat-value"><%= totalDownloads %></div>
                    <div class="stat-label">Total Downloads</div>
                </div>
            </div>
            
            <!-- Charts -->
            <div class="reports-container">
                <div class="report-card">
                    <div class="report-card-header">
                        <h2 class="report-card-title">User Registrations</h2>
                        <button class="export-btn" onclick="exportData('userRegistrations')">
                            <i class="fas fa-download"></i> Export
                        </button>
                    </div>
                    <div class="report-card-body">
                        <canvas id="userRegistrationsChart"></canvas>
                    </div>
                </div>
                
                <div class="report-card">
                    <div class="report-card-header">
                        <h2 class="report-card-title">Book Downloads</h2>
                        <button class="export-btn" onclick="exportData('bookDownloads')">
                            <i class="fas fa-download"></i> Export
                        </button>
                    </div>
                    <div class="report-card-body">
                        <canvas id="bookDownloadsChart"></canvas>
                    </div>
                </div>
                
                <div class="report-card">
                    <div class="report-card-header">
                        <h2 class="report-card-title">Books by Category</h2>
                        <button class="export-btn" onclick="exportData('booksByCategory')">
                            <i class="fas fa-download"></i> Export
                        </button>
                    </div>
                    <div class="report-card-body">
                        <canvas id="booksByCategoryChart"></canvas>
                    </div>
                </div>
                
                <div class="report-card">
                    <div class="report-card-header">
                        <h2 class="report-card-title">Top Authors</h2>
                        <button class="export-btn" onclick="exportData('topAuthors')">
                            <i class="fas fa-download"></i> Export
                        </button>
                    </div>
                    <div class="report-card-body">
                        <canvas id="topAuthorsChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Top Books Table -->
            <div class="report-card">
                <div class="report-card-header">
                    <h2 class="report-card-title">Top Books by Downloads</h2>
                    <button class="export-btn" onclick="exportData('topBooks')">
                        <i class="fas fa-download"></i> Export
                    </button>
                </div>
                <div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Downloads</th>
                                <th>Views</th>
                                <th>Rating</th>
                            </tr>
                        </thead>
                        <tbody id="topBooksTableBody">
                            <!-- Will be populated by AJAX -->
                            <tr>
                                <td colspan="6" class="text-center">Loading data...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Active Users Table -->
            <div class="report-card" style="margin-top: 20px;">
                <div class="report-card-header">
                    <h2 class="report-card-title">Most Active Users</h2>
                    <button class="export-btn" onclick="exportData('activeUsers')">
                        <i class="fas fa-download"></i> Export
                    </button>
                </div>
                <div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Downloads</th>
                                <th>Reviews</th>
                                <th>Last Login</th>
                            </tr>
                        </thead>
                        <tbody id="activeUsersTableBody">
                            <!-- Will be populated by AJAX -->
                            <tr>
                                <td colspan="6" class="text-center">Loading data...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Chart.js configuration
        Chart.defaults.font.family = "'Poppins', 'Helvetica', 'Arial', sans-serif";
        Chart.defaults.color = '#6c757d';
        
        // Initialize charts
        let userRegistrationsChart, bookDownloadsChart, booksByCategoryChart, topAuthorsChart;
        
        // Fetch data and update charts
        function updateCharts() {
            const timeRange = document.getElementById('timeRangeFilter').value;
            
            // Fetch user registrations data
            fetch('../AdminReportServlet?action=userRegistrations&timeRange=' + timeRange)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    updateUserRegistrationsChart(data);
                })
                .catch(error => {
                    console.error('Error fetching user registrations data:', error);
                    // Display dummy data for demonstration
                    const dummyData = {
                        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
                        values: [5, 8, 12, 7, 10, 15, 9]
                    };
                    updateUserRegistrationsChart(dummyData);
                });
            
            // Fetch book downloads data
            fetch('../AdminReportServlet?action=bookDownloads&timeRange=' + timeRange)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    updateBookDownloadsChart(data);
                })
                .catch(error => {
                    console.error('Error fetching book downloads data:', error);
                    // Display dummy data for demonstration
                    const dummyData = {
                        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
                        values: [15, 22, 18, 25, 30, 28, 35]
                    };
                    updateBookDownloadsChart(dummyData);
                });
            
            // Fetch books by category data
            fetch('../AdminReportServlet?action=booksByCategory')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    updateBooksByCategoryChart(data);
                })
                .catch(error => {
                    console.error('Error fetching books by category data:', error);
                    // Display dummy data for demonstration
                    const dummyData = {
                        labels: ['Fiction', 'Science', 'History', 'Biography', 'Technology', 'Self-Help'],
                        values: [45, 30, 25, 20, 35, 15]
                    };
                    updateBooksByCategoryChart(dummyData);
                });
            
            // Fetch top authors data
            fetch('../AdminReportServlet?action=topAuthors&limit=5')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    updateTopAuthorsChart(data);
                })
                .catch(error => {
                    console.error('Error fetching top authors data:', error);
                    // Display dummy data for demonstration
                    const dummyData = {
                        labels: ['John Smith', 'Jane Doe', 'Robert Johnson', 'Emily Wilson', 'Michael Brown'],
                        values: [12, 10, 8, 7, 6]
                    };
                    updateTopAuthorsChart(dummyData);
                });
            
            // Fetch top books data
            fetch('../AdminReportServlet?action=topBooks&limit=10')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    updateTopBooksTable(data);
                })
                .catch(error => {
                    console.error('Error fetching top books data:', error);
                    // Display dummy data for demonstration
                    updateTopBooksTable([
                        {title: 'The Great Novel', author: 'John Smith', category: 'Fiction', downloads: 120, views: 350, rating: 4.5},
                        {title: 'Science Explained', author: 'Jane Doe', category: 'Science', downloads: 95, views: 280, rating: 4.2},
                        {title: 'History of Europe', author: 'Robert Johnson', category: 'History', downloads: 85, views: 240, rating: 4.0},
                        {title: 'Tech Innovations', author: 'Emily Wilson', category: 'Technology', downloads: 75, views: 220, rating: 4.3},
                        {title: 'Self Improvement', author: 'Michael Brown', category: 'Self-Help', downloads: 70, views: 200, rating: 3.9}
                    ]);
                });
            
            // Fetch active users data
            fetch('../AdminReportServlet?action=activeUsers&limit=10')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    updateActiveUsersTable(data);
                })
                .catch(error => {
                    console.error('Error fetching active users data:', error);
                    // Display dummy data for demonstration
                    updateActiveUsersTable([
                        {name: 'Alice Johnson', email: 'alice@example.com', role: 'USER', downloads: 25, reviews: 8, lastLogin: '2023-05-15 14:30:00'},
                        {name: 'Bob Smith', email: 'bob@example.com', role: 'USER', downloads: 18, reviews: 5, lastLogin: '2023-05-14 10:15:00'},
                        {name: 'Carol Davis', email: 'carol@example.com', role: 'USER', downloads: 15, reviews: 6, lastLogin: '2023-05-13 16:45:00'},
                        {name: 'David Wilson', email: 'david@example.com', role: 'USER', downloads: 12, reviews: 3, lastLogin: '2023-05-12 09:20:00'},
                        {name: 'Eva Brown', email: 'eva@example.com', role: 'USER', downloads: 10, reviews: 4, lastLogin: '2023-05-11 11:30:00'}
                    ]);
                });
        }
        
        // Update user registrations chart
        function updateUserRegistrationsChart(data) {
            const ctx = document.getElementById('userRegistrationsChart').getContext('2d');
            
            if (userRegistrationsChart) {
                userRegistrationsChart.destroy();
            }
            
            userRegistrationsChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: 'New Users',
                        data: data.values,
                        backgroundColor: 'rgba(40, 167, 69, 0.2)',
                        borderColor: '#28a745',
                        borderWidth: 2,
                        tension: 0.3,
                        pointBackgroundColor: '#28a745'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    }
                }
            });
        }
        
        // Update book downloads chart
        function updateBookDownloadsChart(data) {
            const ctx = document.getElementById('bookDownloadsChart').getContext('2d');
            
            if (bookDownloadsChart) {
                bookDownloadsChart.destroy();
            }
            
            bookDownloadsChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: 'Downloads',
                        data: data.values,
                        backgroundColor: 'rgba(220, 53, 69, 0.2)',
                        borderColor: '#dc3545',
                        borderWidth: 2,
                        tension: 0.3,
                        pointBackgroundColor: '#dc3545'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    }
                }
            });
        }
        
        // Update books by category chart
        function updateBooksByCategoryChart(data) {
            const ctx = document.getElementById('booksByCategoryChart').getContext('2d');
            
            if (booksByCategoryChart) {
                booksByCategoryChart.destroy();
            }
            
            // Generate colors for each category
            const colors = generateColors(data.labels.length);
            
            booksByCategoryChart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: data.labels,
                    datasets: [{
                        data: data.values,
                        backgroundColor: colors,
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right',
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const label = context.label || '';
                                    const value = context.raw || 0;
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = Math.round((value / total) * 100);
                                    return label + ': ' + value + ' (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });
        }
        
        // Update top authors chart
        function updateTopAuthorsChart(data) {
            const ctx = document.getElementById('topAuthorsChart').getContext('2d');
            
            if (topAuthorsChart) {
                topAuthorsChart.destroy();
            }
            
            topAuthorsChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: 'Books',
                        data: data.values,
                        backgroundColor: 'rgba(255, 193, 7, 0.6)',
                        borderColor: '#ffc107',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        x: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    }
                }
            });
        }
        
        // Update top books table
        function updateTopBooksTable(data) {
            const tableBody = document.getElementById('topBooksTableBody');
            tableBody.innerHTML = '';
            
            if (data.length === 0) {
                const row = document.createElement('tr');
                row.innerHTML = '<td colspan="6" class="text-center">No data available</td>';
                tableBody.appendChild(row);
                return;
            }
            
            data.forEach(book => {
                const row = document.createElement('tr');
                
                // Format rating with stars
                const ratingStars = formatRatingStars(book.rating);
                
                row.innerHTML = `
                    <td>${book.title}</td>
                    <td>${book.author}</td>
                    <td>${book.category}</td>
                    <td>${book.downloads}</td>
                    <td>${book.views}</td>
                    <td>${ratingStars}</td>
                `;
                
                tableBody.appendChild(row);
            });
        }
        
        // Update active users table
        function updateActiveUsersTable(data) {
            const tableBody = document.getElementById('activeUsersTableBody');
            tableBody.innerHTML = '';
            
            if (data.length === 0) {
                const row = document.createElement('tr');
                row.innerHTML = '<td colspan="6" class="text-center">No data available</td>';
                tableBody.appendChild(row);
                return;
            }
            
            data.forEach(user => {
                const row = document.createElement('tr');
                
                // Format role with badge
                let roleBadge = '';
                switch (user.role) {
                    case 'ADMIN':
                        roleBadge = '<span class="badge bg-danger">Admin</span>';
                        break;
                    case 'AUTHOR':
                        roleBadge = '<span class="badge bg-primary">Author</span>';
                        break;
                    default:
                        roleBadge = '<span class="badge bg-secondary">User</span>';
                }
                
                row.innerHTML = `
                    <td>${user.name}</td>
                    <td>${user.email}</td>
                    <td>${roleBadge}</td>
                    <td>${user.downloads}</td>
                    <td>${user.reviews}</td>
                    <td>${formatDate(user.lastLogin)}</td>
                `;
                
                tableBody.appendChild(row);
            });
        }
        
        // Format rating as stars
        function formatRatingStars(rating) {
            const fullStars = Math.floor(rating);
            const halfStar = rating % 1 >= 0.5;
            const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
            
            let stars = '';
            
            // Full stars
            for (let i = 0; i < fullStars; i++) {
                stars += '<i class="fas fa-star text-warning"></i>';
            }
            
            // Half star
            if (halfStar) {
                stars += '<i class="fas fa-star-half-alt text-warning"></i>';
            }
            
            // Empty stars
            for (let i = 0; i < emptyStars; i++) {
                stars += '<i class="far fa-star text-warning"></i>';
            }
            
            return stars + ' <span class="text-muted">(' + rating.toFixed(1) + ')</span>';
        }
        
        // Format date
        function formatDate(dateString) {
            if (!dateString) return 'Never';
            
            const date = new Date(dateString);
            return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
        }
        
        // Generate colors for charts
        function generateColors(count) {
            const colors = [
                'rgba(74, 109, 167, 0.7)',
                'rgba(40, 167, 69, 0.7)',
                'rgba(255, 193, 7, 0.7)',
                'rgba(220, 53, 69, 0.7)',
                'rgba(23, 162, 184, 0.7)',
                'rgba(108, 117, 125, 0.7)',
                'rgba(111, 66, 193, 0.7)',
                'rgba(253, 126, 20, 0.7)'
            ];
            
            // If we need more colors than we have, generate them
            if (count > colors.length) {
                for (let i = colors.length; i < count; i++) {
                    const r = Math.floor(Math.random() * 255);
                    const g = Math.floor(Math.random() * 255);
                    const b = Math.floor(Math.random() * 255);
                    colors.push('rgba(' + r + ', ' + g + ', ' + b + ', 0.7)');
                }
            }
            
            return colors.slice(0, count);
        }
        
        // Export data to CSV
        function exportData(reportType) {
            // In a real application, this would call a servlet to generate a CSV file
            // For this example, we'll just show an alert
            alert('Exporting ' + reportType + ' data to CSV...');
            
            // Example of how this would work with a real endpoint:
            // window.location.href = '../AdminReportServlet?action=export&report=' + reportType;
        }
        
        // Initialize charts on page load
        document.addEventListener('DOMContentLoaded', function() {
            updateCharts();
        });
    </script>
</body>
</html>
