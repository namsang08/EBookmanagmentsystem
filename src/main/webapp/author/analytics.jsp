<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="dao.ReviewDAO"%>
<%@ page import="dao.UserHistoryDAO"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Calendar"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        
        .filter-controls {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .filter-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .filter-label {
            font-weight: 500;
            white-space: nowrap;
        }
        
        .chart-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            margin-bottom: 30px;
        }
        
        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .chart-title {
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .chart-canvas {
            width: 100%;
            height: 300px;
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
        
        .stat-card-icon.views {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .stat-card-icon.downloads {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .stat-card-icon.ratings {
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
        
        .book-performance-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .book-performance-table th, .book-performance-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        .book-performance-table th {
            font-weight: 600;
            color: var(--text-light);
        }
        
        .book-performance-table tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .progress-bar {
            height: 8px;
            background-color: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
        }
        
        .progress-bar-fill {
            height: 100%;
            border-radius: 4px;
        }
        
        .progress-bar-fill.views {
            background-color: #28a745;
        }
        
        .progress-bar-fill.downloads {
            background-color: #ffc107;
        }
        
        .progress-bar-fill.rating {
            background-color: #dc3545;
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .filter-controls {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in and is an author
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() != User.Role.AUTHOR) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get author's books
    BookDAO bookDAO = new BookDAO();
    ReviewDAO reviewDAO = new ReviewDAO();
    UserHistoryDAO userHistoryDAO = new UserHistoryDAO();
    List<Book> authorBooks = new ArrayList<>();
    
    try {
        authorBooks = bookDAO.getBooksByAuthor(user.getUserId());
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Calculate statistics
    int totalBooks = authorBooks.size();
    int totalViews = 0;
    int totalDownloads = 0;
    double totalRating = 0;
    int ratedBooks = 0;
    
    for (Book book : authorBooks) {
        totalViews += book.getViews();
        totalDownloads += book.getDownloads();
        if (book.getRating() > 0) {
            totalRating += book.getRating();
            ratedBooks++;
        }
    }
    
    double averageRating = ratedBooks > 0 ? totalRating / ratedBooks : 0;
    
    // Get time period from request parameter or default to 30 days
    int timePeriod = 30;
    try {
        String periodParam = request.getParameter("period");
        if (periodParam != null) {
            timePeriod = Integer.parseInt(periodParam);
        }
    } catch (NumberFormatException e) {
        // Use default
    }
    
    // Get selected book from request parameter or default to all books
    int selectedBookId = 0;
    try {
        String bookParam = request.getParameter("bookId");
        if (bookParam != null) {
            selectedBookId = Integer.parseInt(bookParam);
        }
    } catch (NumberFormatException e) {
        // Use default
    }
    
    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat chartDateFormat = new SimpleDateFormat("MMM dd");
    String currentDate = dateFormat.format(new Date());
    
    // Generate dates for chart (last X days)
    List<String> chartDates = new ArrayList<>();
    List<Integer> viewsData = new ArrayList<>();
    List<Integer> downloadsData = new ArrayList<>();
    
    Calendar cal = Calendar.getInstance();
    cal.add(Calendar.DAY_OF_MONTH, -timePeriod + 1); // Start from X days ago
    
    // Initialize with zeros
    Map<String, Integer> viewsByDate = new HashMap<>();
    Map<String, Integer> downloadsByDate = new HashMap<>();
    
    // If a specific book is selected, get its history
    if (selectedBookId > 0) {
        try {
            viewsByDate = userHistoryDAO.getViewCountByDate(selectedBookId, timePeriod);
            downloadsByDate = userHistoryDAO.getDownloadCountByDate(selectedBookId, timePeriod);
        } catch (Exception e) {
            e.printStackTrace();
        }
    } else {
        // Aggregate data for all books (simplified for this example)
        // In a real implementation, you would query the database for aggregated data
        for (Book book : authorBooks) {
            try {
                Map<String, Integer> bookViews = userHistoryDAO.getViewCountByDate(book.getBookId(), timePeriod);
                Map<String, Integer> bookDownloads = userHistoryDAO.getDownloadCountByDate(book.getBookId(), timePeriod);
                
                // Merge data
                for (Map.Entry<String, Integer> entry : bookViews.entrySet()) {
                    viewsByDate.put(entry.getKey(), viewsByDate.getOrDefault(entry.getKey(), 0) + entry.getValue());
                }
                
                for (Map.Entry<String, Integer> entry : bookDownloads.entrySet()) {
                    downloadsByDate.put(entry.getKey(), downloadsByDate.getOrDefault(entry.getKey(), 0) + entry.getValue());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    // Generate chart data for the last X days
    for (int i = 0; i < timePeriod; i++) {
        Date date = cal.getTime();
        String dateStr = chartDateFormat.format(date);
        chartDates.add(dateStr);
        
        // Format date for map lookup (yyyy-MM-dd)
        SimpleDateFormat sqlDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        String sqlDateStr = sqlDateFormat.format(date);
        
        // Get views and downloads for this date
        int views = viewsByDate.getOrDefault(sqlDateStr, 0);
        int downloads = downloadsByDate.getOrDefault(sqlDateStr, 0);
        
        viewsData.add(views);
        downloadsData.add(downloads);
        
        cal.add(Calendar.DAY_OF_MONTH, 1);
    }
    
    // Find max values for progress bars
    int maxViews = 0;
    int maxDownloads = 0;
    double maxRating = 0;
    
    for (Book book : authorBooks) {
        if (book.getViews() > maxViews) maxViews = book.getViews();
        if (book.getDownloads() > maxDownloads) maxDownloads = book.getDownloads();
        if (book.getRating() > maxRating) maxRating = book.getRating();
    }
    
    // Ensure we don't divide by zero
    if (maxViews == 0) maxViews = 1;
    if (maxDownloads == 0) maxDownloads = 1;
    if (maxRating == 0) maxRating = 5;
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
                <h2>Author Dashboard</h2>
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="upload-book.jsp"><i class="fas fa-upload"></i> Upload Book</a></li>
                <li><a href="analytics.jsp" class="active"><i class="fas fa-chart-line"></i> Analytics</a></li>
                <li><a href="reviews.jsp"><i class="fas fa-star"></i> Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">Analytics</h1>
                <div class="date">
                    <i class="far fa-calendar-alt"></i> <%= currentDate %>
                </div>
            </div>
            
            <div class="filter-controls">
                <div class="filter-group">
                    <span class="filter-label">Time Period:</span>
                    <select id="timePeriod" class="form-control" onchange="updateFilters()">
                        <option value="7" <%= timePeriod == 7 ? "selected" : "" %>>Last 7 Days</option>
                        <option value="30" <%= timePeriod == 30 ? "selected" : "" %>>Last 30 Days</option>
                        <option value="90" <%= timePeriod == 90 ? "selected" : "" %>>Last 90 Days</option>
                        <option value="365" <%= timePeriod == 365 ? "selected" : "" %>>Last Year</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <span class="filter-label">Book:</span>
                    <select id="bookFilter" class="form-control" onchange="updateFilters()">
                        <option value="0" <%= selectedBookId == 0 ? "selected" : "" %>>All Books</option>
                        <% for (Book book : authorBooks) { %>
                        <option value="<%= book.getBookId() %>" <%= selectedBookId == book.getBookId() ? "selected" : "" %>><%= book.getTitle() %></option>
                        <% } %>
                    </select>
                </div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalBooks %></div>
                            <div class="stat-card-label">Published Books</div>
                        </div>
                        <div class="stat-card-icon books">
                            <i class="fas fa-book"></i>
                        </div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalViews %></div>
                            <div class="stat-card-label">Total Views</div>
                        </div>
                        <div class="stat-card-icon views">
                            <i class="fas fa-eye"></i>
                        </div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalDownloads %></div>
                            <div class="stat-card-label">Total Downloads</div>
                        </div>
                        <div class="stat-card-icon downloads">
                            <i class="fas fa-download"></i>
                        </div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= String.format("%.1f", averageRating) %></div>
                            <div class="stat-card-label">Average Rating</div>
                        </div>
                        <div class="stat-card-icon ratings">
                            <i class="fas fa-star"></i>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="chart-container">
                <div class="chart-header">
                    <h2 class="chart-title">Views & Downloads</h2>
                    <div class="chart-actions">
                        <button class="btn-secondary" onclick="downloadChart('activityChart')">
                            <i class="fas fa-download"></i> Export
                        </button>
                    </div>
                </div>
                <canvas id="activityChart" class="chart-canvas"></canvas>
            </div>
            
            <div class="chart-container">
                <div class="chart-header">
                    <h2 class="chart-title">Book Performance</h2>
                </div>
                
                <table class="book-performance-table">
                    <thead>
                        <tr>
                            <th>Book Title</th>
                            <th>Views</th>
                            <th>Downloads</th>
                            <th>Rating</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Book book : authorBooks) { %>
                        <tr>
                            <td><%= book.getTitle() %></td>
                            <td>
                                <div><%= book.getViews() %></div>
                                <div class="progress-bar">
                                    <div class="progress-bar-fill views" style="width: <%= (book.getViews() * 100) / maxViews %>%"></div>
                                </div>
                            </td>
                            <td>
                                <div><%= book.getDownloads() %></div>
                                <div class="progress-bar">
                                    <div class="progress-bar-fill downloads" style="width: <%= (book.getDownloads() * 100) / maxDownloads %>%"></div>
                                </div>
                            </td>
                            <td>
                                <div><%= book.getRating() > 0 ? String.format("%.1f", book.getRating()) : "N/A" %></div>
                                <div class="progress-bar">
                                    <div class="progress-bar-fill rating" style="width: <%= book.getRating() > 0 ? (book.getRating() * 100) / 5 : 0 %>%"></div>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        
                        <% if (authorBooks.isEmpty()) { %>
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 20px;">
                                <p>You haven't published any books yet.</p>
                                <a href="upload-book.jsp" class="btn-primary" style="display: inline-block; margin-top: 10px;">Upload Your First Book</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            
            <div class="chart-container">
                <div class="chart-header">
                    <h2 class="chart-title">Engagement Metrics</h2>
                </div>
                <canvas id="engagementChart" class="chart-canvas"></canvas>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Update filters
        function updateFilters() {
            const period = document.getElementById('timePeriod').value;
            const bookId = document.getElementById('bookFilter').value;
            
            window.location.href = 'analytics.jsp?period=' + period + '&bookId=' + bookId;
        }
        
        // Download chart as image
        function downloadChart(chartId) {
            const canvas = document.getElementById(chartId);
            const image = canvas.toDataURL('image/png');
            
            const link = document.createElement('a');
            link.download = 'chart-export.png';
            link.href = image;
            link.click();
        }
        
        // Initialize charts
        document.addEventListener('DOMContentLoaded', function() {
            // Activity Chart
            const activityCtx = document.getElementById('activityChart').getContext('2d');
            const activityChart = new Chart(activityCtx, {
                type: 'line',
                data: {
                    labels: <%= chartDates.toString() %>,
                    datasets: [
                        {
                            label: 'Views',
                            data: <%= viewsData.toString() %>,
                            borderColor: '#28a745',
                            backgroundColor: 'rgba(40, 167, 69, 0.1)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: true
                        },
                        {
                            label: 'Downloads',
                            data: <%= downloadsData.toString() %>,
                            borderColor: '#ffc107',
                            backgroundColor: 'rgba(255, 193, 7, 0.1)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: true
                        }
                    ]
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
                            intersect: false
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
            
            // Engagement Chart
            const engagementCtx = document.getElementById('engagementChart').getContext('2d');
            const engagementChart = new Chart(engagementCtx, {
                type: 'bar',
                data: {
                    labels: [<% for (Book book : authorBooks) { %>'<%= book.getTitle() %>', <% } %>],
                    datasets: [
                        {
                            label: 'Downloads per View (%)',
                            data: [<% for (Book book : authorBooks) { %><%= book.getViews() > 0 ? (book.getDownloads() * 100) / book.getViews() : 0 %>, <% } %>],
                            backgroundColor: 'rgba(74, 109, 167, 0.7)',
                            borderColor: 'rgba(74, 109, 167, 1)',
                            borderWidth: 1
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return context.dataset.label + ': ' + context.raw.toFixed(1) + '%';
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Percentage'
                            },
                            ticks: {
                                callback: function(value) {
                                    return value + '%';
                                }
                            }
                        }
                    }
                }
            });
        });
    </script>
</body>
</html>
