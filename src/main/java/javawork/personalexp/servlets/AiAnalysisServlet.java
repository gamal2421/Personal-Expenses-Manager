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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Get user ID from session
        String userEmail = (String) request.getSession().getAttribute("userEmail");
        if (userEmail == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "User not authenticated");
            response.getWriter().write(gson.toJson(errorResponse));
            return;
        }

        int userId = Database.getUserIdByEmail(userEmail);

        // Get selected month and year from request parameters
        int selectedYear = Integer.parseInt(request.getParameter("year"));
        int selectedMonth = Integer.parseInt(request.getParameter("month"));

        // Fetch income and budget data for the user and selected period
        List<Income> incomes = Database.getIncomesByMonth(userId, selectedYear, selectedMonth);
        List<Map<String, Object>> budgets = Database.getAllBudgets(userId, selectedYear, selectedMonth);

        // Prepare data for AI analysis
        JsonObject requestBodyJson = new JsonObject();
        JsonObject contents = new JsonObject();
        List<JsonObject> parts = new ArrayList<>();

        StringBuilder promptBuilder = new StringBuilder();
        promptBuilder.append("Analyze the following financial data for the user for the month of ")
                     .append(selectedMonth).append("/").append(selectedYear).append(":\n\n");

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

        // Construct the new direct prompt
        promptBuilder.setLength(0); // Clear previous prompt content
        promptBuilder.append("I will give you my monthly budget.\n");
        promptBuilder.append("Just tell me directly if it's normal or not, where to reduce spending, where to increase (if needed), and how I can improve saving — all in simple, actionable advice only.\n");
        promptBuilder.append("No summaries or restating my numbers. No long explanations. Just give me the answer.\n\n");
        promptBuilder.append("Here is my budget:\n");

        // Add income data to the prompt
        promptBuilder.append("Income:\n");
        if (incomes != null && !incomes.isEmpty()) {
            for (Income income : incomes) {
                promptBuilder.append("- Source: ").append(income.getSource())
                             .append(", Amount: ").append(income.getAmount()).append("\n");
            }
        } else {
            promptBuilder.append("No income recorded.\n");
        }

        // Add budget data to the prompt
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

        JsonObject textPart = new JsonObject();
        textPart.addProperty("text", prompt);
        parts.add(textPart);

        contents.add("parts", gson.toJsonTree(parts));
        requestBodyJson.add("contents", gson.toJsonTree(List.of(contents)));

        String jsonRequestBody = gson.toJson(requestBodyJson);

        // Call Gemini API using OkHttp
        String aiAnalysis = "Error retrieving analysis.";
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
                    // Parse the JSON response from Gemini API
                    JsonObject geminiResponseJson = gson.fromJson(responseBody, JsonObject.class);
                    if (geminiResponseJson != null && geminiResponseJson.has("candidates")) {
                        // Extract the text from the first candidate's first part
                        JsonObject candidate = geminiResponseJson.getAsJsonArray("candidates").get(0).getAsJsonObject();
                        if (candidate.has("content") && candidate.getAsJsonObject("content").has("parts")) {
                             JsonObject part = candidate.getAsJsonObject("content").getAsJsonArray("parts").get(0).getAsJsonObject();
                             if (part.has("text")) {
                                 aiAnalysis = part.get("text").getAsString();
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
                     // Handle non-successful HTTP responses from the Gemini API
                    aiAnalysis = "Error calling AI API: " + httpResponse.code() + " - " + responseBody;
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
            aiAnalysis = "Error communicating with AI API: " + e.getMessage();
        } catch (JsonSyntaxException e) {
             e.printStackTrace();
             aiAnalysis = "Error parsing AI response: " + e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            aiAnalysis = "An unexpected error occurred: " + e.getMessage();
        }

        // Prepare JSON response for the frontend
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("analysis", aiAnalysis);
        response.getWriter().write(gson.toJson(jsonResponse));
    }
} 