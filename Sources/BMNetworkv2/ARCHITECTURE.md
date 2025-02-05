# BMNetwork Architecture Guide

## Core Principles

1. **Strict Feature Isolation**
   - Each feature has its own namespace and directory
   - Features cannot access other features' implementations
   - All shared functionality must go through the core layer

2. **One-Way Dependencies**
   ```
   Feature Layer (Auth, Encyclopedia, etc.)
          ↓
   Core Layer (NetworkClient, APIEndpoint)
          ↓
   Foundation Layer (URLSession, etc.)
   ```
   - Features depend on core
   - Core never depends on features
   - Features never depend on each other

3. **Authentication Flow**
   - Only Auth feature can handle raw tokens
   - Other features use high-level auth methods
   - Auth state managed centrally through AuthenticationHandler

## Directory Structure

```
BMNetwork/
├── Core/                     # Core networking protocols and types
│   ├── APIEndpoint.swift    # Base endpoint protocol
│   ├── NetworkClient.swift  # Generic networking client
│   └── AuthenticationHandler.swift
│
├── Features/                 # Feature-specific implementations
│   ├── Auth/                # Authentication feature
│   │   ├── AuthEndpoints.swift
│   │   └── AuthService.swift
│   │
│   └── Encyclopedia/        # Encyclopedia feature
│       ├── EncyclopediaEndpoints.swift
│       └── EncyclopediaService.swift
│
└── Utils/                   # Shared utilities
    └── RuntimeChecks.swift  # Runtime safety checks
```

## Feature Implementation Rules

1. **Namespace Declaration**
   ```swift
   enum FeatureEndpoints {
       static var featureNamespace: String { "feature_name" }
   }
   ```

2. **Model Organization**
   - Keep models within feature namespace
   - Use clear type names to avoid conflicts
   - Document all public interfaces

3. **Service Layer**
   - One service per feature
   - Services handle feature-specific logic
   - Use dependency injection

## Runtime Safety

1. **Namespace Validation**
   - Endpoints must declare their namespace
   - Runtime checks prevent cross-namespace access
   - Build-time warnings for common issues

2. **Authentication Safety**
   - Explicit auth requirements in endpoints
   - Runtime validation of auth state
   - Clear error messages for auth issues

## Error Handling

1. **Error Types**
   - Core errors (network, parsing)
   - Feature-specific errors
   - Clear error messages and logging

2. **Error Propagation**
   - Features handle their specific errors
   - Core handles generic errors
   - Proper error transformation

## Testing Strategy

1. **Unit Tests**
   - Test each feature in isolation
   - Mock core dependencies
   - Verify error cases

2. **Integration Tests**
   - Test feature interactions
   - Verify auth flows
   - Test error scenarios
