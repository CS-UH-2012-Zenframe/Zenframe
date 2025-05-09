import Foundation

struct Constants {
    static let baseURL = "http://10.228.249.50:8000"
    
    struct Endpoints {
        static let signup = "/signup"
        static let login = "/login"
        static let news = "/api/news"
        static let me = "/me"
    }
    
    struct Categories {
        static let all = ["world", "politics", "business", "tech", "science", 
                          "health", "sports", "entertainment", "travel", "lifestyle", "other"]
    }
} 
