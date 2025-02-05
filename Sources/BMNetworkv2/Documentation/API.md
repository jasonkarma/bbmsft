# BMNetwork API Documentation

## Core Components

### NetworkClient

The main class for handling network operations. It provides type-safe methods for making API requests with proper error handling and authentication.

```swift
let client = BMNetworkV2.NetworkClient.shared
let response = try await client.send(endpoint)
```

#### Key Methods

1. `send<E: APIEndpoint>(_ endpoint: E) async throws -> E.ResponseType`
   - Basic request without body
   - Uses stored authentication if needed
   - Automatically handles response decoding

2. `send<E: APIEndpoint>(_ endpoint: E, body: E.RequestType?) async throws -> E.ResponseType`
   - Request with optional body
   - Uses stored authentication if needed
   - Validates request/response types

3. `sendWithExplicitAuth<E: APIEndpoint>(_ endpoint: E, body: E.RequestType?, token: String?) async throws -> E.ResponseType`
   - For auth service use only
   - Allows explicit token control
   - Bypasses stored authentication

### Configuration

Controls the behavior of the NetworkClient:

```swift
let config = BMNetworkV2.Configuration(
    defaultHeaders: ["Accept": "application/json"],
    sessionConfiguration: .default,
    requestInterceptors: [LoggingInterceptor()],
    responseInterceptors: [ErrorInterceptor()]
)
```

### APIEndpoint

Protocol for defining API endpoints:

```swift
public struct MyEndpoint: APIEndpoint {
    public typealias RequestType = MyRequest
    public typealias ResponseType = MyResponse
    
    public var path: String { "/api/endpoint" }
    public var method: HTTPMethod { .post }
    public var headers: [String: String]? { nil }
}
```

## Feature: Auth

### Service

```swift
let authService = try BMNetworkV2.Auth.Service(
    client: .shared,
    tokenManager: TokenManager()
)

// Login
let response = try await authService.login(
    email: "user@example.com",
    password: "password"
)

// Register
let newUser = try await authService.register(
    email: "new@example.com",
    username: "newuser",
    password: "password"
)
```

### Models

```swift
// Request
let loginRequest = BMNetworkV2.Auth.LoginRequest(
    email: "user@example.com",
    password: "password"
)

// Response
struct LoginResponse {
    let token: String
    let expiresAt: Date
}
```

## Feature: Encyclopedia

### Service

```swift
let encyclopediaService = try BMNetworkV2.Encyclopedia.Service(
    client: .shared,
    tokenManager: TokenManager()
)

// Get front page
let frontPage = try await encyclopediaService.getFrontPage()

// Get article
let article = try await encyclopediaService.getArticle(id: 1)

// Like article
let likeResponse = try await encyclopediaService.likeArticle(id: 1)
```

### Models

```swift
// Article Preview
struct ArticlePreview: TypeSafeModel {
    let id: Int
    let title: String
    let imageUrl: String?
}

// Full Article
struct ArticleResponse: TypeSafeModel {
    let id: Int
    let title: String
    let content: String
}
```

## Type Safety System

### Type Registration

Register types for runtime validation:

```swift
extension BMNetworkV2.MyFeature {
    static func register() {
        // Register with type registry
        try? TypeRegistry.shared.register(MyType.self, in: featureNamespace)
        
        // Register with type mapping
        TypeMapping.registerModel(MyType.self)
        
        // Register conversions
        TypeMapping.registerConversion(from: TypeA.self, to: TypeB.self)
    }
}
```

### Type Conversion

Convert between compatible types:

```swift
let preview: ArticlePreview = // ...
let article = try preview.convert(to: ArticleResponse.self)
```

## Error Handling

### APIError

```swift
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(String)
    case networkError(Error)
    case decodingError(Error)
}
```

### RuntimeError

```swift
enum RuntimeError: LocalizedError {
    case typeConflict(type: String, feature: String)
    case namespaceConflict(namespace: String)
}
```

## Best Practices

1. **Feature Organization**
   - Keep related code in feature namespace
   - Use proper type registration
   - Follow naming conventions

2. **Error Handling**
   ```swift
   do {
       let response = try await service.someOperation()
   } catch let error as APIError {
       // Handle API errors
   } catch let error as RuntimeError {
       // Handle runtime errors
   } catch {
       // Handle unknown errors
   }
   ```

3. **Testing**
   ```swift
   // Unit test
   func testMyFeature() async throws {
       let service = try MyFeature.Service(
           client: MockNetworkClient(),
           tokenManager: MockTokenManager()
       )
       let response = try await service.operation()
       XCTAssertNotNil(response)
   }
   ```

## Migration Guide

1. **Update Dependencies**
   ```swift
   .package(
       url: "https://github.com/organization/bmnetwork.git",
       from: "2.0.0"
   )
   ```

2. **Register Types**
   ```swift
   MyFeature.register()
   ```

3. **Update Service Usage**
   ```swift
   // Old
   let service = OldService()
   
   // New
   let service = try BMNetworkV2.MyFeature.Service(
       client: .shared,
       tokenManager: TokenManager()
   )
   ```
