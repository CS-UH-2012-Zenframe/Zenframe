import Foundation

// Authentication models
struct SignupRequest: Codable {
    let email: String
    let password: String
    let first_name: String
    let last_name: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable, Identifiable {
    let user_id: String
    let access_token: String
    
    var id: String { user_id }
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case access_token
        case userId
        case accessToken
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try different possible keys for user_id
        if let userId = try? container.decode(String.self, forKey: .user_id) {
            user_id = userId
        } else if let userId = try? container.decode(String.self, forKey: .userId) {
            user_id = userId
        } else {
            // Default to a placeholder if not found
            user_id = "unknown"
        }
        
        // Try different possible keys for access_token
        if let token = try? container.decode(String.self, forKey: .access_token) {
            access_token = token
        } else if let token = try? container.decode(String.self, forKey: .accessToken) {
            access_token = token
        } else if let token = try? container.decode(String.self, forKey: .token) {
            access_token = token
        } else {
            throw DecodingError.dataCorruptedError(forKey: .access_token, in: container, debugDescription: "Access token not found")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(access_token, forKey: .access_token)
    }
}

// News models
struct ArticleSummary: Identifiable, Codable {
    let news_id: String
    let headline: String
    let excerpt: String
    let positivity: Int
    let category: String
    let source_url: String
    let orig_headline: String
    let created_date: DateWrapper
    
    var id: String { news_id }
}

struct DateWrapper: Codable {
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case date = "$date"
    }
}

struct Comment: Identifiable, Codable {
    let comment_id: String
    let user_id: String
    let comment_content: String
    let created_date: DateWrapper
    
    var id: String { comment_id }
}

struct ArticleDetail: Identifiable, Codable {
    let news_id: String
    let headline: String
    let excerpt: String
    let full_body: String
    let positivity: Int
    let category: String
    let source_url: String
    var comments: [Comment]
    
    var id: String { news_id }
}

struct CommentRequest: Codable {
    let comment_content: String
}

struct UserProfile: Codable {
    let user_id: String
    let email: String
    let first_name: String
    let last_name: String
} 