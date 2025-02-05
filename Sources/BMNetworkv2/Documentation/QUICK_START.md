# BMNetwork Quick Start Guide

## Installation

Add BMNetwork to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/organization/bmnetwork.git", from: "2.0.0")
]
```

## Basic Usage

### 1. Initialize Network Client

```swift
import BMNetwork

// Use shared instance
let client = BMNetworkV2.NetworkClient.shared

// Or create custom instance
let config = BMNetworkV2.Configuration(
    defaultHeaders: ["Accept": "application/json"],
    sessionConfiguration: .default
)
let client = BMNetworkV2.NetworkClient(configuration: config)
```

### 2. Authentication

```swift
// Create auth service
let authService = try BMNetworkV2.Auth.Service(
    client: .shared,
    tokenManager: TokenManager()
)

// Login
let loginResponse = try await authService.login(
    email: "user@example.com",
    password: "password123"
)

// Token is automatically managed
print(loginResponse.token)
```

### 3. Using Features

```swift
// Create encyclopedia service
let encyclopediaService = try BMNetworkV2.Encyclopedia.Service(
    client: .shared,
    tokenManager: TokenManager()
)

// Get front page content
let frontPage = try await encyclopediaService.getFrontPage()

// Display articles
for article in frontPage.hotContents {
    print(article.title)
}
```

## Creating New Features

### 1. Define Models

```swift
extension BMNetworkV2.MyFeature {
    public struct MyRequest: TypeSafeModel {
        public let id: Int
        public let name: String
        
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    public struct MyResponse: TypeSafeModel {
        public let success: Bool
        public let data: String
    }
}
```

### 2. Create Endpoints

```swift
extension BMNetworkV2.MyFeature {
    public enum Endpoints {
        public struct MyEndpoint: APIEndpoint {
            public typealias RequestType = MyRequest
            public typealias ResponseType = MyResponse
            
            public var path: String { "/api/my-endpoint" }
            public var method: HTTPMethod { .post }
            
            public init() {}
        }
    }
}
```

### 3. Implement Service

```swift
extension BMNetworkV2.MyFeature {
    public protocol ServiceProtocol {
        func myOperation(id: Int, name: String) async throws -> MyResponse
    }
    
    public final class Service: ServiceProtocol {
        private let client: NetworkClient
        private let tokenManager: TokenManagerProtocol
        
        public init(client: NetworkClient, tokenManager: TokenManagerProtocol) throws {
            self.client = client
            self.tokenManager = tokenManager
        }
        
        public func myOperation(id: Int, name: String) async throws -> MyResponse {
            let endpoint = Endpoints.MyEndpoint()
            let request = MyRequest(id: id, name: name)
            return try await client.send(endpoint, body: request)
        }
    }
}
```

### 4. Register Types

```swift
extension BMNetworkV2.MyFeature {
    public static func register() {
        // Register with type registry
        try? TypeRegistry.shared.register(MyRequest.self, in: featureNamespace)
        try? TypeRegistry.shared.register(MyResponse.self, in: featureNamespace)
        
        // Register with type mapping
        TypeMapping.registerModel(MyRequest.self)
        TypeMapping.registerModel(MyResponse.self)
    }
}
```

## Error Handling

```swift
do {
    let response = try await service.myOperation(id: 1, name: "test")
} catch let error as BMNetworkV2.APIError {
    switch error {
    case .unauthorized:
        // Handle auth error
    case .notFound:
        // Handle not found
    case .serverError(let message):
        // Handle server error
    default:
        // Handle other errors
    }
} catch {
    // Handle unknown errors
}
```

## Testing

### Unit Tests

```swift
final class MyFeatureTests: XCTestCase {
    private var client: MockNetworkClient!
    private var service: BMNetworkV2.MyFeature.Service!
    
    override func setUp() {
        super.setUp()
        client = MockNetworkClient()
        service = try! BMNetworkV2.MyFeature.Service(
            client: client,
            tokenManager: MockTokenManager()
        )
    }
    
    func testMyOperation() async throws {
        // Given
        let expectedResponse = MyResponse(success: true, data: "test")
        client.mockResponse(expectedResponse, for: Endpoints.MyEndpoint())
        
        // When
        let response = try await service.myOperation(id: 1, name: "test")
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data, "test")
    }
}
```

## Common Issues

### 1. Type Not Found
```swift
// Error: Type 'MyType' not found
// Solution: Register type
try? TypeRegistry.shared.register(MyType.self, in: featureNamespace)
```

### 2. Cannot Convert Type
```swift
// Error: Cannot convert from TypeA to TypeB
// Solution: Register conversion
TypeMapping.registerConversion(from: TypeA.self, to: TypeB.self)
```

### 3. Feature Access Denied
```swift
// Error: Feature access denied
// Solution: Validate feature registration
try RuntimeChecks.validateFeatureRegistration(featureNamespace)
```

## Best Practices

1. **Feature Isolation**
   - Keep feature code in its namespace
   - Use proper type registration
   - Follow naming conventions

2. **Type Safety**
   - Always register types
   - Use type-safe models
   - Handle conversion errors

3. **Testing**
   - Write unit tests
   - Test error cases
   - Use mock clients

4. **Error Handling**
   - Use proper error types
   - Handle all cases
   - Provide clear messages

## Need Help?

- Check the [API Documentation](./API.md)
- Review the [Architecture Guide](./ARCHITECTURE.md)
- File issues on GitHub
- Contact the maintainers
