import Foundation


struct ReactionCount: Decodable { let count: Int }

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - Error enum
    enum APIError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(Int)
        case decodingError(Error)
        case unknown(Error)
        case serverError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .invalidResponse: return "Invalid response"
            case .httpError(let code): return "HTTP error: \(code)"
            case .decodingError: return "Failed to decode response"
            case .unknown(let error): return error.localizedDescription
            case .serverError(let message): return "Server error: \(message)"
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private func buildURL(path: String, queryParams: [String: String] = [:]) -> URL? {
        guard var components = URLComponents(string: Constants.baseURL + path) else {
            return nil
        }
        
        if !queryParams.isEmpty {
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components.url
    }
    
    // MARK: - Request Methods
    func authorizedRequest<T: Decodable>(_ path: String, 
                                         method: String = "GET", 
                                         body: Encodable? = nil,
                                         queryParams: [String: String] = [:]) async throws -> T {
        guard let url = buildURL(path: path, queryParams: queryParams) else {
            throw APIError.invalidURL
        }
        
        print("📡 Requesting: \(method) \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📥 Response code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["message"] ?? errorResponse["error"] {
                    throw APIError.serverError(errorMessage)
                }
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding error: \(error)")
                print("❌ Expected type: \(T.self)")
                throw APIError.decodingError(error)
            }
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            throw APIError.decodingError(decodingError)
        } catch {
            print("❌ Request error: \(error)")
            throw APIError.unknown(error)
        }
    }
    
    func request<T: Decodable>(_ path: String, 
                               method: String = "GET", 
                               body: Encodable? = nil,
                               queryParams: [String: String] = [:]) async throws -> T {
        return try await authorizedRequest(path, method: method, body: body, queryParams: queryParams)
    }
    
    // MARK: - Auth Methods
    func signup(email: String, password: String, firstName: String, lastName: String) async throws -> AuthResponse {
        let requestBody = SignupRequest(email: email, password: password, first_name: firstName, last_name: lastName)
        let response: AuthResponse = try await request(Constants.Endpoints.signup, method: "POST", body: requestBody)
        
        // Save token
        UserDefaults.standard.set(response.access_token, forKey: "access_token")
        UserDefaults.standard.set(email, forKey: "user_email")
        UserDefaults.standard.set(firstName, forKey: "user_first_name")
        UserDefaults.standard.set(lastName, forKey: "user_last_name")
        
        return response
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let requestBody = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await request(Constants.Endpoints.login, method: "POST", body: requestBody)
        
        // Save token
        UserDefaults.standard.set(response.access_token, forKey: "access_token")
        UserDefaults.standard.set(email, forKey: "user_email")
        
        return response
    }
    
    // MARK: - News Methods
    func getNews(positivity: Int? = nil, category: String? = nil, limit: Int = 20, offset: Int = 0) async throws -> [ArticleSummary] {
        var queryParams: [String: String] = [
            "limit": "\(limit)",
            "offset": "\(offset)"
        ]
        
        if let positivity = positivity {
            queryParams["positivity"] = "\(positivity)"
        }
        
        if let category = category {
            queryParams["category"] = category
        }
        
        return try await request(Constants.Endpoints.news, queryParams: queryParams)
    }
    
    func getArticleDetail(newsId: String) async throws -> ArticleDetail {
        try await request("\(Constants.Endpoints.news)/\(newsId)")
    }
    
    func addComment(newsId: String, comment: String) async throws -> Comment {
        let requestBody = CommentRequest(comment_content: comment)
        return try await authorizedRequest("\(Constants.Endpoints.news)/\(newsId)/add_comment", 
                                         method: "POST",
                                         body: requestBody)
    }
    
    // MARK: - Reaction Methods
    struct EmptyResponse: Decodable {}

    func addReaction(newsId: String, reactionType: Int) async throws {
        _ = try await authorizedRequest("/api/news/\(newsId)/add_reaction/\(reactionType)", method: "GET") as EmptyResponse
    }

    func getReactionCount(newsId: String, reactionType: Int) async throws -> Int {
        let result: ReactionCount = try await request(
            "/api/news/\(newsId)/get_reaction/\(reactionType)")
        return result.count
    }
    
    // MARK: - User Methods
    func getUserProfile() async throws -> UserProfile {
        try await authorizedRequest(Constants.Endpoints.me)
    }
} 
