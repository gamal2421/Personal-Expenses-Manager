package javawork.personalexp.servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonSyntaxException;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.MediaType;

import java.util.concurrent.TimeUnit;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Calendar;

import javawork.personalexp.tools.Database;
import javawork.personalexp.models.Income;
import javawork.personalexp.models.User;

@WebServlet("/ai_suggests")
public class AiSuggestsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // TODO: Securely manage API Key (e.g., environment variables or a configuration file)
    private static final String API_KEY = "AIzaSyD_oF6xKon_x4bgOvTFBjihAwrWAKSPlNk"; // Replace with your actual API Key
    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=";
    private Gson gson = new Gson();
    private OkHttpClient httpClient;

    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

    @Override
    public void init() throws ServletException {
        super.init();
        httpClient = new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .build();
    }

    @Override
    public void destroy() {
        if (httpClient != null) {
            // Close the connection pool and threads
            httpClient.dispatcher().executorService().shutdown();
            httpClient.connectionPool().evictAll();
        }
        super.destroy();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Get user ID from session
        String userEmail = (String) request.getSession().getAttribute("userEmail");
        if (userEmail == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("reply", "Error: User not authenticated.");
            response.getWriter().write(gson.toJson(errorResponse));
            return;
        }

        int userId = Database.getUserIdByEmail(userEmail);
        if (userId == -1) {
             response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("reply", "Error: User not found.");
            response.getWriter().write(gson.toJson(errorResponse));
            return;
        }

        StringBuilder requestBody = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                requestBody.append(line);
            }
        }

        Gson gson = new Gson();
        JsonObject jsonRequest = gson.fromJson(requestBody.toString(), JsonObject.class);
        String userMessage = jsonRequest.get("message").getAsString();
        JsonArray conversationHistoryJson = jsonRequest.getAsJsonArray("history");

        System.out.println("Received message from frontend: " + userMessage);

        String aiResponseText = "Error getting AI suggestion.";

        try {
            // Get current month and year
            Calendar now = Calendar.getInstance();
            int year = now.get(Calendar.YEAR);
            int month = now.get(Calendar.MONTH) + 1; // Calendar.MONTH is 0-indexed

            // Fetch financial data
            List<Income> incomes = Database.getIncomesByMonth(userId, year, month);
            List<Map<String, Object>> budgets = Database.getAllBudgets(userId, year, month);
            Map<String, Double> monthlyExpenses = Database.getMonthlyExpenses(userId);
            User userInfo = Database.getUserInfo(userId);

            // Construct the prompt for the AI including conversation history and financial data
            List<JsonObject> contents = new ArrayList<>();

            // Add previous messages to contents
            if (conversationHistoryJson != null) {
                for (JsonElement messageElement : conversationHistoryJson) {
                    JsonObject messageObject = messageElement.getAsJsonObject();
                    String role = messageObject.get("role").getAsString();
                    String text = messageObject.get("text").getAsString();

                    JsonObject content = new JsonObject();
                    content.addProperty("role", role.equals("user") ? "user" : "model"); // Map frontend role to API role
                    JsonObject textPart = new JsonObject();
                    textPart.addProperty("text", text);
                    JsonArray parts = new JsonArray();
                    parts.add(textPart);
                    content.add("parts", parts);
                    contents.add(content);
                }
            }

            // Add current user message and financial data to the prompt
            StringBuilder currentPromptBuilder = new StringBuilder();
            currentPromptBuilder.append("Financial Data (Current Month - ").append(month).append("/").append(year).append("):\n");
             if (userInfo != null) {
                 currentPromptBuilder.append("Income Level: ").append(userInfo.getIncomeLevel() != null ? userInfo.getIncomeLevel() : "Not specified").append("\n");
             }

            currentPromptBuilder.append("\nIncome:\n");
            if (incomes != null && !incomes.isEmpty()) {
                for (Income income : incomes) {
                    currentPromptBuilder.append("- Source: ").append(income.getSource())
                                 .append(", Amount: ").append(income.getAmount()).append("\n");
                }
            } else {
                currentPromptBuilder.append("No income recorded.\n");
            }

            currentPromptBuilder.append("\nBudgets:\n");
            if (budgets != null && !budgets.isEmpty()) {
                for (Map<String, Object> budget : budgets) {
                    currentPromptBuilder.append("- Category: ").append(budget.get("category"))
                                 .append(", Budgeted: ").append(budget.get("budget_amount"))
                                 .append(", Spent: ").append(budget.get("current_spending")).append("\n");
                }
            } else {
                currentPromptBuilder.append("No budgets set.\n");
            }

            currentPromptBuilder.append("\nMonthly Expenses (by Category):\n");
             if (monthlyExpenses != null && !monthlyExpenses.isEmpty()) {
                 for (Map.Entry<String, Double> entry : monthlyExpenses.entrySet()) {
                     currentPromptBuilder.append("- ").append(entry.getKey()).append(": ").append(entry.getValue()).append("\n");
                 }
             } else {
                 currentPromptBuilder.append("No expenses recorded for this month.\n");
             }

            currentPromptBuilder.append("\nUser Query: ").append(userMessage).append("\n");
            currentPromptBuilder.append("\nAnalyze the provided financial data and the conversation history. Based *only* on this information, provide relevant financial suggestions or answer the user's question. If the user's question cannot be answered using *only* the provided financial data, or if it is a request for something other than financial analysis or suggestion based on this data (e.g., coding help, general knowledge), politely decline and state that you can only provide assistance related to their personal financial data within this application.");

            JsonObject currentUserContent = new JsonObject();
            currentUserContent.addProperty("role", "user");
            JsonObject currentUserTextPart = new JsonObject();
            currentUserTextPart.addProperty("text", currentPromptBuilder.toString());
            JsonArray currentUserParts = new JsonArray();
            currentUserParts.add(currentUserTextPart);
            currentUserContent.add("parts", currentUserParts);
            contents.add(currentUserContent);

            JsonObject requestBodyJson = new JsonObject();
            requestBodyJson.add("contents", gson.toJsonTree(contents));

            String jsonRequestBody = gson.toJson(requestBodyJson);
            System.out.println("Prompt sent to AI: " + jsonRequestBody); // Log the full request body

            // Call Gemini API
            RequestBody body = RequestBody.create(jsonRequestBody, JSON);

            Request httpRequest = new Request.Builder()
                    .url(GEMINI_API_URL + API_KEY)
                    .addHeader("Content-Type", "application/json")
                    .post(body)
                    .build();

            try (Response httpResponse = httpClient.newCall(httpRequest).execute()) {
                String responseBody = httpResponse.body().string();
                System.out.println("AI API Response: " + responseBody); // Log the AI response

                if (httpResponse.isSuccessful()) {
                    JsonObject geminiResponseJson = gson.fromJson(responseBody, JsonObject.class);
                     if (geminiResponseJson != null && geminiResponseJson.has("candidates") && geminiResponseJson.getAsJsonArray("candidates").size() > 0) {
                        JsonObject candidate = geminiResponseJson.getAsJsonArray("candidates").get(0).getAsJsonObject();
                        if (candidate.has("content") && candidate.getAsJsonObject("content").has("parts") && candidate.getAsJsonObject("content").getAsJsonArray("parts").size() > 0) {
                             JsonObject part = candidate.getAsJsonObject("content").getAsJsonArray("parts").get(0).getAsJsonObject();
                             if (part.has("text")) {
                                 aiResponseText = part.get("text").getAsString();
                             } else {
                                aiResponseText = "Error: Unexpected response format from AI (missing text part in candidate).";
                             }
                        } else {
                             aiResponseText = "Error: Unexpected response format from AI (missing content or parts in candidate).";
                         }
                    } else {
                        aiResponseText = "Error: Unexpected response format from AI (missing candidates or empty candidates list).";
                    }
                } else {
                    aiResponseText = "Error calling AI API: " + httpResponse.code() + " - " + responseBody;
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
            aiResponseText = "Error communicating with AI API: " + e.getMessage();
        } catch (JsonSyntaxException e) {
             e.printStackTrace();
             aiResponseText = "Error parsing AI response: " + e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            aiResponseText = "An unexpected error occurred: " + e.getMessage();
        }

        // Send AI response back to frontend
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("reply", aiResponseText);

        response.getWriter().write(jsonResponse.toString());
    }
} 