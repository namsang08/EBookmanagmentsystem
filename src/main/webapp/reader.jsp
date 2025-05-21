<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO, dao.UserBookDAO, mode.Book, mode.User, mode.UserBook, java.util.*, java.io.*, java.nio.file.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Library Hub Reader</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --reader-bg: #f8f9fa;
            --reader-text: #333;
            --reader-header-bg: #fff;
            --reader-header-text: #333;
            --reader-sidebar-bg: #fff;
            --reader-content-bg: #fff;
            --reader-border: #dee2e6;
            --reader-accent: #4f46e5;
            --reader-accent-hover: #4338ca;
            --reader-font-size: 18px;
            --reader-line-height: 1.8;
            --reader-font-family: 'Georgia', serif;
        }
        
        body.dark-mode {
            --reader-bg: #121212;
            --reader-text: #e0e0e0;
            --reader-header-bg: #1e1e1e;
            --reader-header-text: #f0f0f0;
            --reader-sidebar-bg: #1e1e1e;
            --reader-content-bg: #262626;
            --reader-border: #333;
            --reader-accent: #6366f1;
            --reader-accent-hover: #818cf8;
        }
        
        body.sepia-mode {
            --reader-bg: #f4ecd8;
            --reader-text: #5b4636;
            --reader-header-bg: #f4ecd8;
            --reader-header-text: #5b4636;
            --reader-sidebar-bg: #f4ecd8;
            --reader-content-bg: #fbf7ef;
            --reader-border: #d3c6a6;
            --reader-accent: #8c7851;
            --reader-accent-hover: #6a5a3d;
        }
        
        body {
            margin: 0;
            padding: 0;
            background-color: var(--reader-bg);
            color: var(--reader-text);
            font-family: var(--reader-font-family);
            transition: background-color 0.3s, color 0.3s;
        }
        
        .reader-container {
            display: flex;
            flex-direction: column;
            height: 100vh;
            overflow: hidden;
        }
        
        .reader-header {
            background-color: var(--reader-header-bg);
            color: var(--reader-header-text);
            padding: 10px 20px;
            border-bottom: 1px solid var(--reader-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 10;
        }
        
        .reader-title {
            font-size: 1.2rem;
            font-weight: 500;
            margin: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 50%;
        }
        
        .reader-controls {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .reader-btn {
            background: none;
            border: none;
            color: var(--reader-text);
            cursor: pointer;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            transition: background-color 0.2s;
        }
        
        .reader-btn:hover {
            background-color: rgba(0, 0, 0, 0.05);
        }
        
        body.dark-mode .reader-btn:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .reader-main {
            display: flex;
            flex: 1;
            overflow: hidden;
        }
        
        .reader-sidebar {
            width: 300px;
            background-color: var(--reader-sidebar-bg);
            border-right: 1px solid var(--reader-border);
            overflow-y: auto;
            transition: transform 0.3s;
            z-index: 5;
        }
        
        .reader-sidebar.hidden {
            transform: translateX(-100%);
        }
        
        .sidebar-tabs {
            display: flex;
            border-bottom: 1px solid var(--reader-border);
        }
        
        .sidebar-tab {
            flex: 1;
            text-align: center;
            padding: 15px 0;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            font-weight: 500;
        }
        
        .sidebar-tab.active {
            border-bottom-color: var(--reader-accent);
            color: var(--reader-accent);
        }
        
        .sidebar-content {
            padding: 15px;
        }
        
        .sidebar-panel {
            display: none;
        }
        
        .sidebar-panel.active {
            display: block;
        }
        
        .toc-list {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }
        
        .toc-item {
            padding: 10px 0;
            border-bottom: 1px solid var(--reader-border);
            cursor: pointer;
        }
        
        .toc-item:hover {
            color: var(--reader-accent);
        }
        
        .toc-item.active {
            color: var(--reader-accent);
            font-weight: 500;
        }
        
        .bookmark-list {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }
        
        .bookmark-item {
            padding: 10px 0;
            border-bottom: 1px solid var(--reader-border);
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .bookmark-item:hover {
            color: var(--reader-accent);
        }
        
        .bookmark-remove {
            color: #dc3545;
            cursor: pointer;
            opacity: 0.7;
        }
        
        .bookmark-remove:hover {
            opacity: 1;
        }
        
        .settings-group {
            margin-bottom: 20px;
        }
        
        .settings-title {
            font-weight: 500;
            margin-bottom: 10px;
        }
        
        .font-size-controls {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .font-size-btn {
            background: none;
            border: 1px solid var(--reader-border);
            color: var(--reader-text);
            cursor: pointer;
            width: 36px;
            height: 36px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .font-size-value {
            min-width: 30px;
            text-align: center;
        }
        
        .theme-options {
            display: flex;
            gap: 10px;
        }
        
        .theme-option {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            cursor: pointer;
            border: 2px solid transparent;
            transition: border-color 0.2s;
        }
        
        .theme-option.light {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
        }
        
        .theme-option.dark {
            background-color: #121212;
        }
        
        .theme-option.sepia {
            background-color: #f4ecd8;
        }
        
        .theme-option.active {
            border-color: var(--reader-accent);
        }
        
        .font-family-select {
            width: 100%;
            padding: 8px;
            border: 1px solid var(--reader-border);
            border-radius: 4px;
            background-color: var(--reader-content-bg);
            color: var(--reader-text);
        }
        
        .reader-content-wrapper {
            flex: 1;
            overflow: hidden;
            position: relative;
        }
        
        .reader-content {
            height: 100%;
            overflow-y: auto;
            padding: 40px;
            background-color: var(--reader-content-bg);
            font-size: var(--reader-font-size);
            line-height: var(--reader-line-height);
            max-width: 800px;
            margin: 0 auto;
            position: relative;
        }
        
        .reader-content h1, .reader-content h2, .reader-content h3 {
            margin-top: 1.5em;
            margin-bottom: 0.5em;
        }
        
        .reader-content p {
            margin-bottom: 1em;
        }
        
        .page-controls {
            position: fixed;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 15px;
            background-color: var(--reader-header-bg);
            padding: 10px 20px;
            border-radius: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            z-index: 5;
        }
        
        .page-btn {
            background: none;
            border: none;
            color: var(--reader-text);
            cursor: pointer;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            transition: background-color 0.2s;
        }
        
        .page-btn:hover {
            background-color: rgba(0, 0, 0, 0.05);
        }
        
        body.dark-mode .page-btn:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .page-info {
            font-size: 0.9rem;
            min-width: 80px;
            text-align: center;
        }
        
        .progress-bar-container {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background-color: var(--reader-border);
            z-index: 4;
        }
        
        .progress-bar {
            height: 100%;
            background-color: var(--reader-accent);
            width: 0;
            transition: width 0.3s;
        }
        
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: var(--reader-bg);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 100;
        }
        
        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid rgba(0, 0, 0, 0.1);
            border-radius: 50%;
            border-top-color: var(--reader-accent);
            animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        body.dark-mode .spinner {
            border-color: rgba(255, 255, 255, 0.1);
            border-top-color: var(--reader-accent);
        }
        
        @media (max-width: 768px) {
            .reader-sidebar {
                position: fixed;
                top: 56px;
                left: 0;
                height: calc(100% - 56px);
                z-index: 10;
                box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
            }
            
            .reader-content {
                padding: 20px;
            }
            
            .reader-title {
                max-width: 30%;
            }
        }
    </style>
</head>
<body>
    <%
        // Get book ID from request parameter
        int bookId = 1; // Default to book ID 1 if parameter is missing
        try {
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                bookId = Integer.parseInt(idParam);
            }
        } catch (NumberFormatException e) {
            // Keep default value if parsing fails
        }
        
        // Initialize book data
        String bookTitle = "Loading...";
        String bookContent = "<p>Book content is loading or unavailable.</p>";
        int totalPages = 1;
        int currentPage = 1;
        
        // Check if user is logged in
        User currentUser = null;
        boolean isLoggedIn = false;
        int userId = 0;
        
        try {
            Object userObj = session.getAttribute("user");
            if (userObj != null && userObj instanceof User) {
                currentUser = (User) userObj;
                isLoggedIn = true;
                userId = currentUser.getUserId();
            }
        } catch (Exception e) {
            // If user session check fails, assume not logged in
            isLoggedIn = false;
        }
        
        // Initialize DAOs
        BookDAO bookDAO = null;
        UserBookDAO userBookDAO = null;
        Book book = null;
        UserBook userBook = null;
        
        try {
            // Get book details
            bookDAO = new BookDAO();
            book = bookDAO.getBookById(bookId);
            
            if (book != null) {
                bookTitle = book.getTitle();
                totalPages = book.getPages();
                
                // If user is logged in, get their reading progress
                if (isLoggedIn) {
                    userBookDAO = new UserBookDAO();
                    userBook = userBookDAO.getUserBook(userId, bookId);
                    
                    if (userBook != null) {
                        currentPage = userBook.getCurrentPage();
                        if (currentPage < 1) currentPage = 1;
                        if (currentPage > totalPages) currentPage = totalPages;
                    }
                    
                    // Update reading status to READING if not already
                    if (userBook == null) {
                        userBookDAO.addUserBook(userId, bookId, UserBook.ReadingStatus.READING);
                    } else if (userBook.getReadingStatus() != UserBook.ReadingStatus.READING) {
                        userBookDAO.updateReadingStatus(userId, bookId, UserBook.ReadingStatus.READING);
                    }
                    
                    // Increment view count
                    bookDAO.incrementViews(bookId);
                }
                
                // Load book content
                String filePath = book.getFilePath();
                if (filePath != null && !filePath.isEmpty()) {
                    try {
                        // Get the real path to the file
                        String realPath = application.getRealPath(filePath);
                        File file = new File(realPath);
                        
                        if (file.exists()) {
                            // Read file content
                            StringBuilder contentBuilder = new StringBuilder();
                            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                                String line;
                                while ((line = br.readLine()) != null) {
                                    contentBuilder.append(line).append("\n");
                                }
                            }
                            bookContent = contentBuilder.toString();
                        } else {
                            // Use sample content if file doesn't exist
                            bookContent = getSampleContent(bookId, currentPage);
                        }
                    } catch (Exception e) {
                        // Use sample content if file reading fails
                        bookContent = getSampleContent(bookId, currentPage);
                    }
                } else {
                    // Use sample content if file path is not available
                    bookContent = getSampleContent(bookId, currentPage);
                }
            }
        } catch (Exception e) {
            // If database query fails, use sample content
            bookContent = getSampleContent(bookId, currentPage);
        }
        
        // Get bookmarks if user is logged in
        List<Map<String, Object>> bookmarks = new ArrayList<>();
        if (isLoggedIn && userBookDAO != null) {
            try {
                // This is a placeholder - you would need to implement getBookmarks in UserBookDAO
                // bookmarks = userBookDAO.getBookmarks(userId, bookId);
                
                // Sample bookmarks for demonstration
                Map<String, Object> bookmark1 = new HashMap<>();
                bookmark1.put("page", 5);
                bookmark1.put("title", "Chapter 1: Introduction");
                bookmarks.add(bookmark1);
                
                Map<String, Object> bookmark2 = new HashMap<>();
                bookmark2.put("page", 15);
                bookmark2.put("title", "Chapter 2: Getting Started");
                bookmarks.add(bookmark2);
            } catch (Exception e) {
                // Ignore if getting bookmarks fails
            }
        }
        
        // Generate table of contents
        List<Map<String, Object>> tableOfContents = new ArrayList<>();
        try {
            // This would typically come from the book's metadata or structure
            // For now, we'll create a sample TOC
            String[] chapters = {
                "Introduction", "Chapter 1", "Chapter 2", "Chapter 3", 
                "Chapter 4", "Chapter 5", "Conclusion", "References"
            };
            
            int pagesPerChapter = totalPages / chapters.length;
            for (int i = 0; i < chapters.length; i++) {
                Map<String, Object> chapter = new HashMap<>();
                chapter.put("title", chapters[i]);
                chapter.put("page", i * pagesPerChapter + 1);
                tableOfContents.add(chapter);
            }
        } catch (Exception e) {
            // Ignore if generating TOC fails
        }
    %>
    
    <%!
        // Helper method to generate sample content for a page
        private String getSampleContent(int bookId, int page) {
            StringBuilder content = new StringBuilder();
            
            // Add chapter heading for first page of chapters
            if (page % 10 == 1) {
                int chapterNum = (page / 10) + 1;
                content.append("<h1>Chapter ").append(chapterNum).append("</h1>");
                
                switch (chapterNum) {
                    case 1:
                        content.append("<h2>Introduction</h2>");
                        break;
                    case 2:
                        content.append("<h2>Getting Started</h2>");
                        break;
                    case 3:
                        content.append("<h2>Advanced Concepts</h2>");
                        break;
                    case 4:
                        content.append("<h2>Practical Applications</h2>");
                        break;
                    case 5:
                        content.append("<h2>Case Studies</h2>");
                        break;
                    default:
                        content.append("<h2>Additional Material</h2>");
                }
            }
            
            // Add paragraphs of content
            int paragraphs = 3 + (int)(Math.random() * 3); // 3-5 paragraphs per page
            for (int i = 0; i < paragraphs; i++) {
                content.append("<p>");
                
                // Generate 3-6 sentences per paragraph
                int sentences = 3 + (int)(Math.random() * 4);
                for (int j = 0; j < sentences; j++) {
                    // Sample sentences
                    String[] sampleSentences = {
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
                        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.",
                        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia.",
                        "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.",
                        "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet.",
                        "Consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt.",
                        "Ut labore et dolore magnam aliquam quaerat voluptatem.",
                        "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse."
                    };
                    
                    int index = (bookId * page * i * j) % sampleSentences.length;
                    content.append(sampleSentences[index]).append(" ");
                }
                
                content.append("</p>");
            }
            
            // Add a figure or quote occasionally
            if (page % 5 == 0) {
                content.append("<blockquote>");
                content.append("\"The only way to learn a new programming language is by writing programs in it.\" - Dennis Ritchie");
                content.append("</blockquote>");
            }
            
            return content.toString();
        }
    %>

    <div class="reader-container">
        <!-- Header with controls -->
        <header class="reader-header">
            <h1 class="reader-title"><%= bookTitle %></h1>
            <div class="reader-controls">
                <button id="toggleSidebar" class="reader-btn" title="Toggle Sidebar">
                    <i class="fas fa-bars"></i>
                </button>
                <% if (isLoggedIn) { %>
                    <button id="addBookmark" class="reader-btn" title="Add Bookmark">
                        <i class="far fa-bookmark"></i>
                    </button>
                <% } %>
                <button id="toggleFullscreen" class="reader-btn" title="Toggle Fullscreen">
                    <i class="fas fa-expand"></i>
                </button>
                <a href="bookdetails.jsp?id=<%= bookId %>" class="reader-btn" title="Back to Book Details">
                    <i class="fas fa-times"></i>
                </a>
            </div>
        </header>
        
        <!-- Main content area with sidebar and book content -->
        <div class="reader-main">
            <!-- Sidebar with tabs for TOC, Bookmarks, and Settings -->
            <aside class="reader-sidebar">
                <div class="sidebar-tabs">
                    <div class="sidebar-tab active" data-tab="toc">Contents</div>
                    <div class="sidebar-tab" data-tab="bookmarks">Bookmarks</div>
                    <div class="sidebar-tab" data-tab="settings">Settings</div>
                </div>
                
                <div class="sidebar-content">
                    <!-- Table of Contents Panel -->
                    <div class="sidebar-panel active" id="toc-panel">
                        <ul class="toc-list">
                            <% for (Map<String, Object> chapter : tableOfContents) { %>
                                <li class="toc-item <%= (int)chapter.get("page") == currentPage ? "active" : "" %>" 
                                    data-page="<%= chapter.get("page") %>">
                                    <%= chapter.get("title") %>
                                </li>
                            <% } %>
                        </ul>
                    </div>
                    
                    <!-- Bookmarks Panel -->
                    <div class="sidebar-panel" id="bookmarks-panel">
                        <% if (!isLoggedIn) { %>
                            <p>Please <a href="login.jsp">login</a> to use bookmarks.</p>
                        <% } else if (bookmarks.isEmpty()) { %>
                            <p>No bookmarks yet. Add bookmarks while reading to see them here.</p>
                        <% } else { %>
                            <ul class="bookmark-list">
                                <% for (Map<String, Object> bookmark : bookmarks) { %>
                                    <li class="bookmark-item" data-page="<%= bookmark.get("page") %>">
                                        <span><%= bookmark.get("title") %> (Page <%= bookmark.get("page") %>)</span>
                                        <span class="bookmark-remove" data-page="<%= bookmark.get("page") %>">
                                            <i class="fas fa-times"></i>
                                        </span>
                                    </li>
                                <% } %>
                            </ul>
                        <% } %>
                    </div>
                    
                    <!-- Settings Panel -->
                    <div class="sidebar-panel" id="settings-panel">
                        <div class="settings-group">
                            <div class="settings-title">Font Size</div>
                            <div class="font-size-controls">
                                <button class="font-size-btn" id="decreaseFontSize">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <span class="font-size-value">18px</span>
                                <button class="font-size-btn" id="increaseFontSize">
                                    <i class="fas fa-plus"></i>
                                </button>
                            </div>
                        </div>
                        
                        <div class="settings-group">
                            <div class="settings-title">Theme</div>
                            <div class="theme-options">
                                <div class="theme-option light active" data-theme="light"></div>
                                <div class="theme-option sepia" data-theme="sepia"></div>
                                <div class="theme-option dark" data-theme="dark"></div>
                            </div>
                        </div>
                        
                        <div class="settings-group">
                            <div class="settings-title">Font Family</div>
                            <select class="font-family-select" id="fontFamilySelect">
                                <option value="Georgia, serif">Georgia</option>
                                <option value="'Times New Roman', serif">Times New Roman</option>
                                <option value="Arial, sans-serif">Arial</option>
                                <option value="'Segoe UI', sans-serif">Segoe UI</option>
                                <option value="'Roboto', sans-serif">Roboto</option>
                                <option value="monospace">Monospace</option>
                            </select>
                        </div>
                        
                        <div class="settings-group">
                            <div class="settings-title">Line Spacing</div>
                            <div class="font-size-controls">
                                <button class="font-size-btn" id="decreaseLineHeight">
                                    <i class="fas fa-compress-alt"></i>
                                </button>
                                <span class="line-height-value">1.8</span>
                                <button class="font-size-btn" id="increaseLineHeight">
                                    <i class="fas fa-expand-alt"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </aside>
            
            <!-- Book content area -->
            <div class="reader-content-wrapper">
                <div class="reader-content" id="bookContent">
                    <%= bookContent %>
                </div>
                
                <!-- Page navigation controls -->
                <div class="page-controls">
                    <button class="page-btn" id="prevPage" <%= currentPage <= 1 ? "disabled" : "" %>>
                        <i class="fas fa-chevron-left"></i>
                    </button>
                    <span class="page-info">
                        Page <span id="currentPage"><%= currentPage %></span> of <span id="totalPages"><%= totalPages %></span>
                    </span>
                    <button class="page-btn" id="nextPage" <%= currentPage >= totalPages ? "disabled" : "" %>>
                        <i class="fas fa-chevron-right"></i>
                    </button>
                </div>
                
                <!-- Reading progress bar -->
                <div class="progress-bar-container">
                    <div class="progress-bar" style="width: <%= (currentPage * 100) / totalPages %>%;"></div>
                </div>
                
                <!-- Loading overlay -->
                <div class="loading-overlay" id="loadingOverlay">
                    <div class="spinner"></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Variables
            const bookId = <%= bookId %>;
            const isLoggedIn = <%= isLoggedIn %>;
            const userId = <%= userId %>;
            let currentPage = <%= currentPage %>;
            const totalPages = <%= totalPages %>;
            let fontSize = 18;
            let lineHeight = 1.8;
            
            // Elements
            const toggleSidebarBtn = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.reader-sidebar');
            const sidebarTabs = document.querySelectorAll('.sidebar-tab');
            const sidebarPanels = document.querySelectorAll('.sidebar-panel');
            const tocItems = document.querySelectorAll('.toc-item');
            const bookmarkItems = document.querySelectorAll('.bookmark-item');
            const bookmarkRemoveBtns = document.querySelectorAll('.bookmark-remove');
            const addBookmarkBtn = document.getElementById('addBookmark');
            const toggleFullscreenBtn = document.getElementById('toggleFullscreen');
            const prevPageBtn = document.getElementById('prevPage');
            const nextPageBtn = document.getElementById('nextPage');
            const currentPageSpan = document.getElementById('currentPage');
            const totalPagesSpan = document.getElementById('totalPages');
            const progressBar = document.querySelector('.progress-bar');
            const decreaseFontSizeBtn = document.getElementById('decreaseFontSize');
            const increaseFontSizeBtn = document.getElementById('increaseFontSize');
            const fontSizeValue = document.querySelector('.font-size-value');
            const decreaseLineHeightBtn = document.getElementById('decreaseLineHeight');
            const increaseLineHeightBtn = document.getElementById('increaseLineHeight');
            const lineHeightValue = document.querySelector('.line-height-value');
            const themeOptions = document.querySelectorAll('.theme-option');
            const fontFamilySelect = document.getElementById('fontFamilySelect');
            const bookContent = document.getElementById('bookContent');
            const loadingOverlay = document.getElementById('loadingOverlay');
            
            // Initialize
            hideLoading();
            
            // Event Listeners
            
            // Toggle sidebar
            toggleSidebarBtn.addEventListener('click', function() {
                sidebar.classList.toggle('hidden');
            });
            
            // Sidebar tabs
            sidebarTabs.forEach(tab => {
                tab.addEventListener('click', function() {
                    const tabId = this.getAttribute('data-tab');
                    
                    // Update active tab
                    sidebarTabs.forEach(t => t.classList.remove('active'));
                    this.classList.add('active');
                    
                    // Show corresponding panel
                    sidebarPanels.forEach(panel => panel.classList.remove('active'));
                    document.getElementById(`${tabId}-panel`).classList.add('active');
                });
            });
            
            // Table of Contents navigation
            tocItems.forEach(item => {
                item.addEventListener('click', function() {
                    const page = parseInt(this.getAttribute('data-page'));
                    navigateToPage(page);
                });
            });
            
            // Bookmark navigation
            bookmarkItems.forEach(item => {
                item.addEventListener('click', function(e) {
                    if (!e.target.closest('.bookmark-remove')) {
                        const page = parseInt(this.getAttribute('data-page'));
                        navigateToPage(page);
                    }
                });
            });
            
            // Remove bookmarks
            bookmarkRemoveBtns.forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    const page = parseInt(this.getAttribute('data-page'));
                    removeBookmark(page);
                });
            });
            
            // Add bookmark
            if (addBookmarkBtn) {
                addBookmarkBtn.addEventListener('click', function() {
                    addBookmark(currentPage);
                });
            }
            
            // Toggle fullscreen
            toggleFullscreenBtn.addEventListener('click', function() {
                toggleFullscreen();
            });
            
            // Page navigation
            prevPageBtn.addEventListener('click', function() {
                if (currentPage > 1) {
                    navigateToPage(currentPage - 1);
                }
            });
            
            nextPageBtn.addEventListener('click', function() {
                if (currentPage < totalPages) {
                    navigateToPage(currentPage + 1);
                }
            });
            
            // Font size controls
            decreaseFontSizeBtn.addEventListener('click', function() {
                if (fontSize > 12) {
                    fontSize -= 2;
                    updateFontSize();
                }
            });
            
            increaseFontSizeBtn.addEventListener('click', function() {
                if (fontSize < 32) {
                    fontSize += 2;
                    updateFontSize();
                }
            });
            
            // Line height controls
            decreaseLineHeightBtn.addEventListener('click', function() {
                if (lineHeight > 1.2) {
                    lineHeight -= 0.2;
                    updateLineHeight();
                }
            });
            
            increaseLineHeightBtn.addEventListener('click', function() {
                if (lineHeight < 3.0) {
                    lineHeight += 0.2;
                    updateLineHeight();
                }
            });
            
            // Theme options
            themeOptions.forEach(option => {
                option.addEventListener('click', function() {
                    const theme = this.getAttribute('data-theme');
                    setTheme(theme);
                    
                    // Update active state
                    themeOptions.forEach(opt => opt.classList.remove('active'));
                    this.classList.add('active');
                });
            });
            
            // Font family select
            fontFamilySelect.addEventListener('change', function() {
                document.documentElement.style.setProperty('--reader-font-family', this.value);
            });
            
            // Keyboard navigation
            document.addEventListener('keydown', function(e) {
                if (e.key === 'ArrowLeft') {
                    if (currentPage > 1) {
                        navigateToPage(currentPage - 1);
                    }
                } else if (e.key === 'ArrowRight') {
                    if (currentPage < totalPages) {
                        navigateToPage(currentPage + 1);
                    }
                }
            });
            
            // Functions
            
            function navigateToPage(page) {
                if (page < 1 || page > totalPages || page === currentPage) return;
                
                showLoading();
                
                // Update current page
                currentPage = page;
                currentPageSpan.textContent = currentPage;
                
                // Update progress bar
                progressBar.style.width = `${(currentPage * 100) / totalPages}%`;
                
                // Update navigation buttons
                prevPageBtn.disabled = currentPage <= 1;
                nextPageBtn.disabled = currentPage >= totalPages;
                
                // Update TOC active item
                tocItems.forEach(item => {
                    item.classList.remove('active');
                    if (parseInt(item.getAttribute('data-page')) === currentPage) {
                        item.classList.add('active');
                    }
                });
                
                // Save reading progress if logged in
                if (isLoggedIn) {
                    saveReadingProgress(currentPage);
                }
                
                // Load page content
                loadPageContent(currentPage);
            }
            
            function loadPageContent(page) {
                // In a real application, this would fetch the content from the server
                // For this example, we'll simulate loading with a timeout
                setTimeout(() => {
                    // Generate sample content for the page
                    fetch(`ReaderServlet?action=getPageContent&bookId=${bookId}&page=${page}`)
                        .then(response => response.text())
                        .then(content => {
                            bookContent.innerHTML = content;
                            hideLoading();
                        })
                        .catch(error => {
                            // Fallback to client-side generated content
                            bookContent.innerHTML = generateSampleContent(page);
                            hideLoading();
                        });
                }, 300);
            }
            
            function generateSampleContent(page) {
                let content = '';
                
                // Add chapter heading for first page of chapters
                if (page % 10 === 1) {
                    const chapterNum = Math.floor(page / 10) + 1;
                    content += `<h1>Chapter ${chapterNum}</h1>`;
                    
                    switch (chapterNum) {
                        case 1:
                            content += '<h2>Introduction</h2>';
                            break;
                        case 2:
                            content += '<h2>Getting Started</h2>';
                            break;
                        case 3:
                            content += '<h2>Advanced Concepts</h2>';
                            break;
                        case 4:
                            content += '<h2>Practical Applications</h2>';
                            break;
                        case 5:
                            content += '<h2>Case Studies</h2>';
                            break;
                        default:
                            content += '<h2>Additional Material</h2>';
                    }
                }
                
                // Add paragraphs of content
                const paragraphs = 3 + Math.floor(Math.random() * 3); // 3-5 paragraphs per page
                for (let i = 0; i < paragraphs; i++) {
                    content += '<p>';
                    
                    // Generate 3-6 sentences per paragraph
                    const sentences = 3 + Math.floor(Math.random() * 4);
                    for (let j = 0; j < sentences; j++) {
                        // Sample sentences
                        const sampleSentences = [
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                            "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
                            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.",
                            "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia.",
                            "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.",
                            "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet.",
                            "Consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt.",
                            "Ut labore et dolore magnam aliquam quaerat voluptatem.",
                            "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse."
                        ];
                        
                        const index = (bookId * page * i * j) % sampleSentences.length;
                        content += sampleSentences[index] + ' ';
                    }
                    
                    content += '</p>';
                }
                
                // Add a figure or quote occasionally
                if (page % 5 === 0) {
                    content += '<blockquote>';
                    content += '"The only way to learn a new programming language is by writing programs in it." - Dennis Ritchie';
                    content += '</blockquote>';
                }
                
                return content;
            }
            
            function saveReadingProgress(page) {
                // In a real application, this would send an AJAX request to the server
                fetch('UserBookServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `action=updateProgress&userId=${userId}&bookId=${bookId}&currentPage=${page}`
                }).catch(error => {
                    console.error('Error saving reading progress:', error);
                });
            }
            
            function addBookmark(page) {
                // Get the first few words of the current page as the bookmark title
                let bookmarkTitle = '';
                const firstParagraph = bookContent.querySelector('p');
                if (firstParagraph) {
                    bookmarkTitle = firstParagraph.textContent.substring(0, 30) + '...';
                } else {
                    bookmarkTitle = `Page ${page}`;
                }
                
                // In a real application, this would send an AJAX request to the server
                fetch('UserBookServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `action=addBookmark&userId=${userId}&bookId=${bookId}&page=${page}&title=${encodeURIComponent(bookmarkTitle)}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Add the bookmark to the UI
                        const bookmarksList = document.querySelector('.bookmark-list');
                        if (bookmarksList) {
                            const noBookmarksMsg = bookmarksList.querySelector('p');
                            if (noBookmarksMsg) {
                                bookmarksList.innerHTML = '';
                            }
                            
                            const li = document.createElement('li');
                            li.className = 'bookmark-item';
                            li.setAttribute('data-page', page);
                            li.innerHTML = `
                                <span>${bookmarkTitle} (Page ${page})</span>
                                <span class="bookmark-remove" data-page="${page}">
                                    <i class="fas fa-times"></i>
                                </span>
                            `;
                            bookmarksList.appendChild(li);
                            
                            // Add event listeners to the new bookmark
                            li.addEventListener('click', function(e) {
                                if (!e.target.closest('.bookmark-remove')) {
                                    navigateToPage(page);
                                }
                            });
                            
                            const removeBtn = li.querySelector('.bookmark-remove');
                            removeBtn.addEventListener('click', function(e) {
                                e.stopPropagation();
                                removeBookmark(page);
                            });
                        }
                        
                        // Show a notification
                        alert('Bookmark added!');
                    }
                })
                .catch(error => {
                    console.error('Error adding bookmark:', error);
                    alert('Failed to add bookmark. Please try again.');
                });
            }
            
            function removeBookmark(page) {
                // In a real application, this would send an AJAX request to the server
                fetch('UserBookServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `action=removeBookmark&userId=${userId}&bookId=${bookId}&page=${page}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Remove the bookmark from the UI
                        const bookmarkItem = document.querySelector(`.bookmark-item[data-page="${page}"]`);
                        if (bookmarkItem) {
                            bookmarkItem.remove();
                            
                            // If no bookmarks left, show a message
                            const bookmarksList = document.querySelector('.bookmark-list');
                            if (bookmarksList && bookmarksList.children.length === 0) {
                                bookmarksList.innerHTML = '<p>No bookmarks yet. Add bookmarks while reading to see them here.</p>';
                            }
                        }
                    }
                })
                .catch(error => {
                    console.error('Error removing bookmark:', error);
                });
            }
            
            function toggleFullscreen() {
                const container = document.querySelector('.reader-container');
                
                if (!document.fullscreenElement) {
                    if (container.requestFullscreen) {
                        container.requestFullscreen();
                    } else if (container.mozRequestFullScreen) { /* Firefox */
                        container.mozRequestFullScreen();
                    } else if (container.webkitRequestFullscreen) { /* Chrome, Safari & Opera */
                        container.webkitRequestFullscreen();
                    } else if (container.msRequestFullscreen) { /* IE/Edge */
                        container.msRequestFullscreen();
                    }
                    toggleFullscreenBtn.innerHTML = '<i class="fas fa-compress"></i>';
                } else {
                    if (document.exitFullscreen) {
                        document.exitFullscreen();
                    } else if (document.mozCancelFullScreen) { /* Firefox */
                        document.mozCancelFullScreen();
                    } else if (document.webkitExitFullscreen) { /* Chrome, Safari & Opera */
                        document.webkitExitFullscreen();
                    } else if (document.msExitFullscreen) { /* IE/Edge */
                        document.msExitFullscreen();
                    }
                    toggleFullscreenBtn.innerHTML = '<i class="fas fa-expand"></i>';
                }
            }
            
            function updateFontSize() {
                document.documentElement.style.setProperty('--reader-font-size', `${fontSize}px`);
                fontSizeValue.textContent = `${fontSize}px`;
            }
            
            function updateLineHeight() {
                document.documentElement.style.setProperty('--reader-line-height', lineHeight.toFixed(1));
                lineHeightValue.textContent = lineHeight.toFixed(1);
            }
            
            function setTheme(theme) {
                document.body.classList.remove('light-mode', 'dark-mode', 'sepia-mode');
                document.body.classList.add(`${theme}-mode`);
            }
            
            function showLoading() {
                loadingOverlay.style.display = 'flex';
            }
            
            function hideLoading() {
                loadingOverlay.style.display = 'none';
            }
        });
    </script>
</body>
</html>
