// Basic JavaScript for sending messages (will need backend integration)
const chatContainer = document.getElementById('chat-container');
const inputElement = document.getElementById('user-input');
const sendButton = document.getElementById('send-button');

// Get context path from the hidden div
const contextDataElement = document.getElementById('context-data');
const contextPath = contextDataElement ? contextDataElement.dataset.contextPath : '';

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
        const servletPath = '/ai_suggests';
        const servletUrl = contextPath + servletPath; // Use the dynamically retrieved contextPath

        fetch(servletUrl, { 
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