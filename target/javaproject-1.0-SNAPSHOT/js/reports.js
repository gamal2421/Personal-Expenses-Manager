document.addEventListener('DOMContentLoaded', function() {
    // Profile click event
    document.getElementById('profile-section').addEventListener('click', function() {
        console.log("Profile clicked - can implement popup here");
    });

    // Notification button click
    const notificationBtn = document.querySelector('.notification-btn');
    if (notificationBtn) {
        notificationBtn.addEventListener('click', function() {
            console.log("Notifications clicked - can implement notifications here");
        });
    }

    // Settings button click
    const settingsBtn = document.querySelector('.settings-btn');
    if (settingsBtn) {
        settingsBtn.addEventListener('click', function() {
            console.log("Settings clicked - can implement settings here");
        });
    }

    function fetchAiAnalysis() {
        const reportDateInput = document.getElementById('reportDate');
        const selectedDate = reportDateInput.value;
        let year = 0;
        let month = 0;

        if (selectedDate) {
            const [selectedYear, selectedMonth] = selectedDate.split('-');
            year = parseInt(selectedYear);
            month = parseInt(selectedMonth);
        }

        const aiAnalysisDiv = document.getElementById('ai-analysis-content');
        aiAnalysisDiv.innerHTML = '<p>Loading AI analysis...</p>'; // Show loading message

        // Get context path from a data attribute
        const contextPathElement = document.getElementById('context-path-data');
        const contextPath = contextPathElement ? contextPathElement.dataset.contextPath : '';

        const servletPath = '/AiAnalysisServlet';
        const servletUrl = contextPath + servletPath;

        console.log('Fetching AI analysis from: ' + servletUrl);

        fetch(servletUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ year: year, month: month }) // Send data in JSON body
        })
            .then(response => {
                if (!response.ok) {
                    // If response is not OK (e.g., 404, 500), read as text to see if it\'s an HTML error page
                    return response.text().then(text => { throw new Error('HTTP error! status: ' + response.status + ', body: ' + text); });
                }
                return response.json(); // Otherwise, parse as JSON
            })
            .then(data => {
                const aiAnalysisDiv = document.getElementById('ai-analysis-content');
                aiAnalysisDiv.innerHTML = ''; // Clear loading message

                if (data.analysis) {
                    // Split the analysis into sections (e.g., by double newline)
                    const sections = data.analysis.split(/\n\s*\n/);

                    // Create a container for the cards
                    const cardsContainer = document.createElement('div');
                    cardsContainer.classList.add('ai-analysis-cards');

                    sections.forEach(section => {
                        if (section.trim() !== '') {
                            // Create a card for each section
                            const card = document.createElement('div');
                            card.classList.add('ai-analysis-card');

                            // Add the section content to the card (replace single newlines with <br>)
                            card.innerHTML = '<p>' + section.trim().replace(/\n/g, '<br>') + '</p>';

                            cardsContainer.appendChild(card);
                        }
                    });

                    aiAnalysisDiv.appendChild(cardsContainer);

                } else if (data.error) {
                    aiAnalysisDiv.innerHTML = '<p>Error: ' + data.error + '</p>';
                } else {
                    aiAnalysisDiv.innerHTML = '<p>Could not retrieve AI analysis.</p>';
                }
            })
            .catch(error => {
                console.error('Error fetching AI analysis:', error);
                aiAnalysisDiv.innerHTML = '<p>Error loading AI analysis: ' + error.message + '</p>';
            });
    }

    // Fetch analysis when the page loads
    fetchAiAnalysis();

    // You might want to add an event listener to the filter form if you want
    // the AI analysis to update without a full page reload when the filter changes.
    // For now, it updates on page load which happens after filter submission.
}); 