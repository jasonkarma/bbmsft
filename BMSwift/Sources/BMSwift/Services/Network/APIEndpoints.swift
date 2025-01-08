import Foundation

public enum APIEndpoints {
    public enum Auth {
        public static func login(request: LoginRequest) -> APIEndpoint {
            APIEndpoint(
                path: "/login",
                method: .post,
                body: request
            )
        }
        
        // Add more auth-related endpoints here
    }
    
    public enum User {
        // Add user-related endpoints here
    }
    
    public enum Media {
        // Add media-related endpoints here
    }
}
