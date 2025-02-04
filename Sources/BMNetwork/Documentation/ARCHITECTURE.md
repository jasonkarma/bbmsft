# BMNetwork Architecture

## Overview

BMNetwork is a type-safe, feature-isolated networking layer designed for scalability and maintainability. It follows a strict modular architecture that prevents cross-feature dependencies and ensures type safety at both compile-time and runtime.

## Core Principles

### 1. Feature Isolation
- Each feature (Auth, Encyclopedia, etc.) is completely isolated
- No cross-feature dependencies allowed
- Runtime checks prevent unauthorized access
- Clear namespace boundaries

### 2. Type Safety
- Compile-time type checking through protocol conformance
- Runtime type validation and registration
- Safe type conversion system
- Clear error messages for type conflicts

### 3. Authentication Flow
- Centralized token management
- Secure token storage
- Clear authentication state handling
- Feature-level access control

## Directory Structure

```
BMNetwork/
├── Core/
│   ├── NetworkClient.swift       # Core networking functionality
│   ├── APIEndpoint.swift         # Endpoint protocol definitions
│   ├── RuntimeChecks.swift       # Runtime safety validation
│   ├── TypeMapping.swift         # Type conversion system
│   └── TypeNamespaces.swift      # Feature namespace management
├── Auth/
│   ├── AuthEndpoints.swift       # Authentication endpoints
│   ├── AuthService.swift         # Authentication service
│   └── AuthModels.swift          # Authentication models
├── Encyclopedia/
│   ├── EncyclopediaEndpoints.swift
│   ├── EncyclopediaService.swift
│   └── EncyclopediaModels.swift
└── Documentation/
    └── ARCHITECTURE.md           # This file

```

## Feature Implementation Guide

### 1. Define Models
```swift
extension BMNetworkV2.FeatureName {
    public struct MyModel: TypeSafeModel {
        // Properties
    }
}
```

### 2. Create Endpoints
```swift
extension BMNetworkV2.FeatureName {
    public enum Endpoints {
        public struct MyEndpoint: APIEndpoint {
            public typealias RequestType = MyRequest
            public typealias ResponseType = MyResponse
        }
    }
}
```

### 3. Implement Service
```swift
extension BMNetworkV2.FeatureName {
    public protocol ServiceProtocol {
        // Define interface
    }
    
    public final class Service: ServiceProtocol {
        // Implement interface
    }
}
```

## Type Safety System

### 1. Type Registration
All types must be registered with both systems:
```swift
// Type Registry for runtime validation
try? TypeRegistry.shared.register(MyType.self, in: featureNamespace)

// Type Mapping for safe conversions
TypeMapping.registerModel(MyType.self)
```

### 2. Type Conversion
Define valid conversions between types:
```swift
TypeMapping.registerConversion(from: PreviewType.self, to: DetailType.self)
```

### 3. Runtime Checks
Validate feature access and registration:
```swift
try RuntimeChecks.validateFeatureAccess(featureNamespace)
try RuntimeChecks.validateFeatureRegistration(featureNamespace)
```

## Error Handling

### 1. Network Errors
```swift
public enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(String)
    case networkError(Error)
    case decodingError(Error)
}
```

### 2. Type System Errors
```swift
public enum RuntimeError: LocalizedError {
    case typeConflict(type: String, feature: String)
    case namespaceConflict(namespace: String)
}
```

## Testing Strategy

### 1. Unit Tests
- Test individual components
- Mock dependencies
- Test error cases

### 2. Integration Tests
- Test feature flows
- Test cross-feature interactions
- Test concurrent operations

### 3. Type Safety Tests
- Test type registration
- Test type conversion
- Test runtime checks

## Best Practices

1. **Feature Isolation**
   - Keep features self-contained
   - Use proper namespacing
   - Avoid cross-feature dependencies

2. **Type Safety**
   - Always register types
   - Define clear conversion rules
   - Use runtime checks

3. **Error Handling**
   - Provide clear error messages
   - Handle all error cases
   - Use proper error types

4. **Testing**
   - Write comprehensive tests
   - Test edge cases
   - Test error scenarios

## Migration Guide

### Phase 1: Network Layer
- Implement core functionality
- Add type safety system
- Add runtime checks
- Write tests

### Phase 2: Service Layer
- Create new service interfaces
- Implement using new network layer
- Keep old services working
- Add integration tests

### Phase 3: UI Migration
- Create new UI components
- Use new service layer
- Migrate features gradually
- Remove old code when ready
