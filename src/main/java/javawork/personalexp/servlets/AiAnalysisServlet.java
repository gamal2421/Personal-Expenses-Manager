package javawork.personalexp.servlets;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;

import javawork.personalexp.tools.Database;
import javawork.personalexp.models.Income;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.MediaType;

import java.io.BufferedReader;
import java.io.InputStreamReader;

@WebServlet("/AiAnalysisServlet")
public class AiAnalysisServlet extends HttpServlet {

    private static final String API_KEY = "AIzaSyD_oF6xKon_x4bgOvTFBjihAwrWAKSPlNk";
    private Gson gson = new Gson();
    private OkHttpClient httpClient;

    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");
    // Use a supported model name for v1beta API
    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=";


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

    // Define Message class here for use in doPost
    private static class Message {
        public String role;
        public String text;

        public Message(String role, String text) {
            this.role = role;
            this.text = text;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Check if user is authenticated
        String userEmail = (String) request.getSession().getAttribute("userEmail");
        if (userEmail == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "User not authenticated");
            response.getWriter().write(gson.toJson(errorResponse));
            return;
        }

        StringBuilder jsonRequest = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonRequest.append(line);
            }
        }

        try {
            JsonObject requestJson = gson.fromJson(jsonRequest.toString(), JsonObject.class);

            // Extract year and month from the JSON request
            int year = 0;
            int month = 0;

            if (requestJson.has("year")) {
                year = requestJson.get("year").getAsInt();
            }
            if (requestJson.has("month")) {
                month = requestJson.get("month").getAsInt();
            }

            // If year or month are 0, default to current year and month
            java.util.Calendar cal = java.util.Calendar.getInstance();
            int currentYear = cal.get(java.util.Calendar.YEAR);
            int currentMonth = cal.get(java.util.Calendar.MONTH) + 1; // Calendar.MONTH is 0-indexed

            if (year == 0) {
                year = currentYear;
            }
            if (month == 0) {
                month = currentMonth;
            }

            // Fetch income and budget data for the user
            int userId = Database.getUserIdByEmail(userEmail);
            
            List<Income> incomes = Database.getIncomesByMonth(userId, year, month);
            List<Map<String, Object>> budgets = Database.getAllBudgets(userId, year, month);

            // Build the prompt for Gemini API
            StringBuilder promptBuilder = new StringBuilder();
            promptBuilder.append("You are an AI financial assistant. Analyze the user's financial situation based on their income and budget data for the selected period. Provide simple, actionable advice. Avoid restating numbers unless necessary for context. Do not include summaries or long explanations unless explicitly asked.\n\n");
            
            promptBuilder.append("Financial Data (for the month of ").append(month).append("/").append(year).append("):\n");

            promptBuilder.append("Income:\n");
            if (incomes != null && !incomes.isEmpty()) {
                for (Income income : incomes) {
                    promptBuilder.append("- Source: ").append(income.getSource())
                                 .append(", Amount: ").append(income.getAmount()).append("\n");
                }
            } else {
                promptBuilder.append("No income recorded.\n");
            }

            promptBuilder.append("\nBudgets:\n");
            if (budgets != null && !budgets.isEmpty()) {
                for (Map<String, Object> budget : budgets) {
                    promptBuilder.append("- Category: ").append(budget.get("category"))
                                 .append(", Budgeted: ").append(budget.get("budget_amount"))
                                 .append(", Spent: ").append(budget.get("current_spending")).append("\n");
                }
            } else {
                promptBuilder.append("No budgets set.\n");
            }

            String prompt = promptBuilder.toString();

            // Prepare request body for Gemini API
            JsonObject contents = new JsonObject();
            List<JsonObject> parts = new ArrayList<>();
            JsonObject textPart = new JsonObject();
            textPart.addProperty("text", prompt);
            parts.add(textPart);
            contents.add("parts", gson.toJsonTree(parts));
            JsonObject requestBodyJson = new JsonObject();
            requestBodyJson.add("contents", gson.toJsonTree(List.of(contents)));
            String jsonRequestBody = gson.toJson(requestBodyJson);

            // Call Gemini API using OkHttp
            String aiAnalysis = "Error retrieving analysis from AI."; // Default error message
            try {
                RequestBody body = RequestBody.create(jsonRequestBody, JSON);

                Request httpRequest = new Request.Builder()
                        .url(GEMINI_API_URL + API_KEY)
                        .addHeader("Content-Type", "application/json")
                        .post(body)
                        .build();

                try (Response httpResponse = httpClient.newCall(httpRequest).execute()) {
                    String responseBody = httpResponse.body().string();

                    if (httpResponse.isSuccessful()) {
                        JsonObject geminiResponseJson = gson.fromJson(responseBody, JsonObject.class);
                        if (geminiResponseJson != null && geminiResponseJson.has("candidates")) {
                            JsonObject candidate = geminiResponseJson.getAsJsonArray("candidates").get(0).getAsJsonObject();
                            if (candidate.has("content") && candidate.getAsJsonObject("content").has("parts")) {
                                 JsonObject part = candidate.getAsJsonObject("content").getAsJsonArray("parts").get(0).getAsJsonObject();
                                 if (part.has("text")) {
                                     // Ensure the JsonElement is not null before converting to string
                                     com.google.gson.JsonElement textElement = part.get("text");
                                     if (textElement != null && !textElement.isJsonNull()) {
                                         aiAnalysis = textElement.getAsString();
                                     } else {
                                         aiAnalysis = "Error: AI response text is null or empty.";
                                     }
                                 } else {
                                    aiAnalysis = "Error: Unexpected response format from AI (missing text part).";
                                 }
                            } else {
                                 aiAnalysis = "Error: Unexpected response format from AI (missing content or parts).";
                            }
                        } else {
                            aiAnalysis = "Error: Unexpected response format from AI (missing candidates).";
                        }
                    } else {
                        aiAnalysis = "Error calling AI API: " + httpResponse.code() + " - " + responseBody;
                    }
                }

            } catch (IOException e) {
                e.printStackTrace();
                aiAnalysis = "Error communicating with AI API: " + e.getMessage();
            } catch (JsonSyntaxException e) {
                 e.printStackTrace();
                 aiAnalysis = "Error parsing AI response from Gemini: " + e.getMessage();
            } catch (Exception e) {
                e.printStackTrace();
                aiAnalysis = "An unexpected error occurred during AI call: " + e.getMessage();
            }

            // Prepare JSON response for the frontend
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("analysis", aiAnalysis);
            response.getWriter().write(gson.toJson(jsonResponse));

        } catch (JsonSyntaxException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "Invalid JSON format in request: " + e.getMessage());
            response.getWriter().write(gson.toJson(errorResponse));
            e.printStackTrace();
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "An unexpected server error occurred: " + e.getMessage());
            response.getWriter().write(gson.toJson(errorResponse));
            e.printStackTrace();
        }
    }
} 