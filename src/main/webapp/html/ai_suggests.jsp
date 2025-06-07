<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>

<%! // Define a class or methods for AI interaction here or import one
    // This is a placeholder. You will need to implement or integrate your actual AI logic.
    public class AIService {
        public String getSuggestion(List<Message> history, String newMessage) {
            // TODO: Implement actual AI interaction logic here.
            // This is a mock response.
            System.out.println("AI received message: " + newMessage);
            System.out.println("Conversation History: " + history);
            return "This is a mock AI suggestion based on your input: \"" + newMessage + "\"";
        }
    }

    // Simple Message class to hold chat history
    public class Message {
        public String role;
        public String text;

        public Message(String role, String text) {
            this.role = role;
            this.text = text;
        }

        @Override
        public String toString() {
            return role + ": " + text;
        }
    }
%>

<%
    // Check if the user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return; // Stop further processing if not logged in
    }

    // Fetch user information for the sidebar
    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);

    // Set content type for JSON response (only applies if this is a POST request)
    // This is handled later in the POST block for a clean response.
    // response.setContentType("application/json");
    // response.setCharacterEncoding("UTF-8");

    // Handle POST request for sending a new message
    if ("POST".equals(request.getMethod())) {
        response.setContentType("application/json"); // Set here for POST
        response.setCharacterEncoding("UTF-8"); // Set here for POST

        StringBuilder jsonRequest = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonRequest.append(line);
            }
        }

        JSONObject requestJson = new JSONObject(jsonRequest.toString());
        String userMessage = requestJson.getString("message");
        JSONArray historyJson = requestJson.getJSONArray("history");

        List<Message> conversationHistory = new ArrayList<>();
        for (int i = 0; i < historyJson.length(); i++) {
            JSONObject msgJson = historyJson.getJSONObject(i);
            conversationHistory.add(new Message(msgJson.getString("role"), msgJson.getString("text")));
        }

        // Add the current user message to history for the AI
        conversationHistory.add(new Message("user", userMessage));

        // Call the AI Service (Placeholder)
        AIService aiService = new AIService();
        String aiReply = aiService.getSuggestion(conversationHistory, userMessage);

        // Prepare JSON response
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("reply", aiReply);

        // Send response
        response.getWriter().write(jsonResponse.toString());
        return; // Stop further JSP processing for POST requests
    }

    // Handle GET request for initial page load (optional: fetch history if stored)
    // For now, the initial message is hardcoded in HTML/JS.

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">



    <!-- Apple Touch Icon (iOS) -->
    <link rel="apple-touch-icon" sizes="180x180" href="/icons/apple-touch-icon.png">
    <!-- Android Chrome -->
    <link rel="icon" type="image/png" sizes="192x192" href="/icons/android-chrome-192x192.png">
    <link rel="icon" type="image/png" sizes="512x512" href="/icons/android-chrome-512x512.png">
    <!-- Favicon -->
    <link rel="icon" type="image/png" sizes="32x32" href="/icons/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/icons/favicon-16x16.png">
    <!-- Optional: Web Manifest for PWA -->
    <link rel="manifest" href="/icons/site.webmanifest">
    



    <title>AI Suggestions</title>
    <link rel="stylesheet" href="../css/all.min.css"> <%-- Link to Font Awesome --%>


    <link rel="stylesheet" href="../css/dashboard.css"> <%-- Link to dashboard styles --%>
    <style>
        /* Improved chat styling */
        #chat-container {
            width: 100%;
            margin: 0 auto 20px auto;
            border: 1px solid #e0e0e0; /* Lighter border */
            border-radius: 8px;
            padding: 15px;
            height: 400px;
            overflow-y: auto; /* Use auto for scrollbar only when needed */
            background-color: #ffffff; /* White background for clarity */
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08); /* Stronger subtle shadow */
            display: flex; /* Use flexbox for message layout */
            flex-direction: column;
        }
        .message {
            margin-bottom: 15px; /* Increased space between messages */
            padding: 10px 15px; /* Adjusted padding */
            border-radius: 20px; /* More rounded corners for bubbles */
            max-width: 85%; /* Slightly increased max width */
            word-wrap: break-word; /* Prevent long words from overflowing */
            line-height: 1.4; /* Improved readability */
        }
        .user-message {
            align-self: flex-end; /* Align to the right */
            background-color: #dcf8c6; /* Light green bubble */
            color: #333333; /* Dark text */
            margin-left: auto; /* Ensure it sticks to the right */
            border-bottom-right-radius: 5px; /* Less rounded corner on the bubble tip side */
        }
        .ai-message {
            align-self: flex-start; /* Align to the left */
            background-color: #e9e9eb; /* Light grey bubble */
            color: #333333; /* Dark text */
            margin-right: auto; /* Ensure it sticks to the left */
            border-bottom-left-radius: 5px; /* Less rounded corner on the bubble tip side */
        }
        #input-container {
            width: 100%;
            margin: 0 auto;
            display: flex;
            gap: 10px;
            align-items: center;
            padding-top: 10px; /* Add some space above the input */
        }
        #user-input {
            flex-grow: 1;
            padding: 12px 20px; /* Increased padding */
            border: 1px solid #cccccc; /* Lighter border */
            border-radius: 25px; /* Fully rounded corners */
            font-size: 16px;
            outline: none; /* Remove default outline */
            transition: border-color 0.3s ease; /* Smooth transition for focus */
        }
        #user-input:focus {
            border-color: #3ab19b; /* Highlight color on focus */
        }
        #send-button {
            padding: 12px 25px; /* Increased padding */
            background-color: #3ab19b;
            color: white;
            border: none;
            border-radius: 25px; /* Fully rounded corners */
            cursor: pointer;
            transition: background-color 0.3s ease;
            font-size: 16px;
            text-transform: uppercase; /* Make button text uppercase */
            font-weight: bold; /* Bold button text */
        }
        #send-button:hover {
            background-color: #1abc9c;
        }
    </style>
</head>
<body>
    <%-- Assuming sidebar is handled by an include or parent page --%>
    <div class="main-page">
        <div id="sidebar">
            <%-- Profile Section --%>
            <div id="profile-section">
                <div class="profile-image">
                    <img src="https://e7.pngegg.com/pngimages/442/16/png-clipart-computer-icons-man-icon-logo-silhouette.png" alt="Profile">
                </div>
                <h3><%= user != null ? user.getUsername() : "Guest" %></h3>
                <p><%= user != null ? user.getEmail() : "N/A" %></p>
            </div>

            <%-- Navigation Menu --%>
            <ul class="nav-menu">
                <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Dashboard</a></li>
                <li class="nav-item"><a href="Financials goals.jsp"><i class="icons fas fa-wallet"></i> Financials</a></li>
                <li class="nav-item"><a href="reports.jsp"><i class="icons fas fa-file-alt"></i> Reports</a></li>
                <li class="nav-item"><a href="budget.jsp"><i class="icons fas fa-money-bill-wave"></i> Budget</a></li>
                <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
                <li class="nav-item"><a href="categories.jsp"><i class="icons fas fa-tags"></i> Categories</a></li>
                <li class="nav-item"><a href="expenses.jsp"><i class="icons fas fa-shopping-cart"></i> Expenses</a></li>
                <li class="nav-item"><a href="ai_suggests.jsp"><i class="icons fas fa-lightbulb"></i> AI Suggests</a></li>
                <li class="nav-item"><a href="logout.jsp"><i class="icons fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </div>
        <div class="content-area">
            <div class="top-bar">
                <div class="page-title">
                    <h1>AI Financial Suggestions</h1>
                </div>
                <%-- Optional: Add top actions here if needed --%>
                <div class="top-actions">
                    <%-- Example: <div class="notification-btn"><i class="fas fa-bell"></i></div> --%>
                    <%-- Example: <div class="settings-btn"><i class="fas fa-cog"></i></div> --%>
                </div>
            </div>

            <div class="dashboard-content"> <%-- Using dashboard-content for the main area --%>
                <%-- Existing chat container and input will go here --%>
                <div id="chat-container">
                    <!-- Chat messages will appear here -->
                    <%-- Initial AI message handled by JS, or could be fetched here --%>
                    <div class="message ai-message">Hello! I am your AI financial assistant. How can I help you today?</div>
                </div>

                <div id="input-container">
                    <input type="text" id="user-input" placeholder="Type your message here...">
                    <button id="send-button">Send</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Basic JavaScript for sending messages (will need backend integration)
        const chatContainer = document.getElementById('chat-container');
        const inputElement = document.getElementById('user-input');
        const sendButton = document.getElementById('send-button');

        // Array to store conversation history
        // Initialize with the first AI message
        const conversationHistory = [{ role: 'ai', text: 'Hello! I am your AI financial assistant. How can I help you today?' }];

        sendButton.addEventListener('click', sendMessage);
        inputElement.addEventListener('keypress', function(event) {
            if (event.key === 'Enter') {
                sendMessage();
            }
        });

        // Function to add a message to the UI and history
        function addMessage(sender, text) {
            const messageDiv = document.createElement('div');
            messageDiv.classList.add('message', sender === 'user' ? 'user-message' : 'ai-message');
            messageDiv.textContent = text;
            chatContainer.appendChild(messageDiv);
            chatContainer.scrollTop = chatContainer.scrollHeight; // Auto-scroll to bottom

            // Add to history
            conversationHistory.push({ role: sender, text: text });
        }

        function sendMessage() {
            const messageText = inputElement.value.trim();

            if (messageText) {
                // Display user message and add to history immediately
                addMessage('user', messageText);

                // Clear input immediately
                inputElement.value = '';

                // Prepare data to send (including history)
                const dataToSend = {
                    message: messageText,
                    history: conversationHistory // Send the whole history
                };

                // Send messageText and history to backend/AI (the Servlet)
                fetch('/Personal-Expenses-Manager/ai_suggests', { // Sending to the AiSuggestsServlet
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(dataToSend)
                })
                .then(response => response.json())
                .then(data => {
                    // Display AI response and add to history
                    if (data.reply) {
                        addMessage('ai', data.reply);
                    } else if (data.error) {
                         addMessage('ai', 'Error: ' + data.error);
                    } else {
                         addMessage('ai', 'Error: Could not get a valid response from AI.');
                    }

                })
                .catch(error => {
                    console.error('Error sending message:', error);
                    addMessage('ai', 'Error: Could not communicate with the server.');
                });
            }
        }
    </script>
</body>
</html> 