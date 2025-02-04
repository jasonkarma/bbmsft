import XCTest
@testable import BMNetwork

final class TypeRegistryTests: XCTestCase {
    // MARK: - Test Doubles
    
    private enum TestFeature: FeatureTypeRegistry {
        static var featureId: String { "test_feature" }
        
        struct TestType1 {}
        struct TestType2 {}
        
        static func register() {
            try? TypeRegistry.shared.register(TestType1.self, in: featureId)
            try? TypeRegistry.shared.register(TestType2.self, in: featureId)
        }
    }
    
    private enum ConflictingFeature: FeatureTypeRegistry {
        static var featureId: String { "conflicting_feature" }
        
        // Same name as TestFeature.TestType1
        struct TestType1 {}
        
        static func register() {
            try? TypeRegistry.shared.register(TestType1.self, in: featureId)
        }
    }
    
    // MARK: - Tests
    
    override func setUp() {
        super.setUp()
        // Reset type registry before each test
        TypeRegistry.shared.reset()
    }
    
    func testTypeRegistrationSuccess() throws {
        // When
        TestFeature.register()
        
        // Then
        XCTAssertTrue(TypeRegistry.shared.isRegistered(TestFeature.TestType1.self, in: TestFeature.featureId))
        XCTAssertTrue(TypeRegistry.shared.isRegistered(TestFeature.TestType2.self, in: TestFeature.featureId))
    }
    
    func testTypeRegistrationConflict() throws {
        // Given
        TestFeature.register()
        
        // When/Then
        XCTAssertThrowsError(try TypeRegistry.shared.register(
            TestFeature.TestType1.self,
            in: TestFeature.featureId
        )) { error in
            guard let runtimeError = error as? BMNetworkV2.RuntimeError else {
                XCTFail("Expected RuntimeError")
                return
            }
            
            switch runtimeError {
            case .typeConflict(let type, let feature):
                XCTAssertEqual(type, "TestType1")
                XCTAssertEqual(feature, TestFeature.featureId)
            default:
                XCTFail("Expected typeConflict error")
            }
        }
    }
    
    func testDifferentFeaturesCanHaveSameTypeNames() throws {
        // Given
        TestFeature.register()
        
        // When/Then - Should not throw
        XCTAssertNoThrow(try TypeRegistry.shared.register(
            ConflictingFeature.TestType1.self,
            in: ConflictingFeature.featureId
        ))
    }
}

// MARK: - Test Helpers

private extension TypeRegistry {
    func reset() {
        // Reset for testing
        registeredFeatures.removeAll()
        registeredTypes.removeAll()
    }
    
    func isRegistered(_ type: Any.Type, in featureId: String) -> Bool {
        let typeName = String(describing: type)
        return registeredTypes[featureId]?.contains(typeName) ?? false
    }
}
