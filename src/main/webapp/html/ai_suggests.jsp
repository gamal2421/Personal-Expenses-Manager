<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Suggests</title>
    <link rel="stylesheet" href="../css/style.css"> <!-- Assuming a main CSS file -->
    <style>
        /* Basic chat styling */
        #chat-container {
            width: 80%;
            margin: 20px auto;
            border: 1px solid #ccc;
            padding: 10px;
            height: 400px;
            overflow-y: scroll;
        }
        .message {
            margin-bottom: 10px;
        }
        .user-message {
            text-align: right;
            color: blue;
        }
        .ai-message {
            text-align: left;
            color: green;
        }
        #input-container {
            width: 80%;
            margin: 10px auto;
            display: flex;
        }
        #user-input {
            flex-grow: 1;
            padding: 8px;
            margin-right: 10px;
        }
        #send-button {
            padding: 8px 15px;
        }
    </style>
</head>
<body>
    <h1>AI Financial Suggestions</h1>

    <div id="chat-container">
        <!-- Chat messages will appear here -->
        <div class="message ai-message">Hello! I am your AI financial assistant. How can I help you today?</div>
    </div>

    <div id="input-container">
        <input type="text" id="user-input" placeholder="Type your message here...">
        <button id="send-button">Send</button>
    </div>

    <script>
        // Basic JavaScript for sending messages (will need backend integration)
        const chatContainer = document.getElementById('chat-container');
        const inputElement = document.getElementById('user-input');
        const sendButton = document.getElementById('send-button');

        // Array to store conversation history
        const conversationHistory = [];

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

            // Add to history (simple text for now, can enhance later if needed)
            conversationHistory.push({ role: sender, text: text });
        }

        // Initial AI message
        addMessage('ai', 'Hello! I am your AI financial assistant. How can I help you today?');


        function sendMessage() {
            const messageText = inputElement.value.trim();

            if (messageText) {
                // Display user message and add to history
                addMessage('user', messageText);

                // Clear input immediately
                inputElement.value = '';

                // Prepare data to send (including history)
                const dataToSend = {
                    message: messageText,
                    history: conversationHistory // Send the whole history
                };

                // Send messageText and history to backend/AI
                fetch('/Personal-Expenses-Manager/ai_suggests', { // TODO: Verify context path if needed
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