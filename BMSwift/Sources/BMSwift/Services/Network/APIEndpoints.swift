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
        
        public static func forgotPassword(request: ForgotPasswordRequest) -> APIEndpoint {
            APIEndpoint(
                path: "/forgot-password",
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
