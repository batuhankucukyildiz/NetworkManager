import XCTest
@testable import NetworkManager

final class NetworkManagerTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    /// Test is done by the demo API https://jsonplaceholder.typicode.com
    func testSuccessfullNetworkCase() async throws {
        let manager = NetworkManager.shared
        let endpoint = MockEndpointProtocol(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/todos/1",
            httpMethod: .get,
            params: nil,
            headers: nil
        )
                
        do {
            let data: MockResponseModel? = try await manager.request(endpoint)
            XCTAssertNotNil(data)
        } catch {
            XCTFail("Request failed with error: \(error)")
        }
    }
    
    func testFailureNetworkCase() async throws {
        let manager = NetworkManager.shared
        let endpoint = MockEndpointProtocol(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/todo",
            httpMethod: .get,
            params: nil,
            headers: nil
        )
                
        do {
            let _: MockResponseModel = try await manager.request(endpoint)
            XCTFail("Expected request to fail, but it succeeded.")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
        
        let emptyURL = MockEndpointProtocol(
            baseURL: "",
            path: "",
            httpMethod: .get,
            params: nil,
            headers: nil
        )
        
        do {
            let _: MockResponseModel = try await manager.request(emptyURL)
            XCTFail("Expected request to fail, but it succeeded.")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
        
        let emptyRequest = MockEndpointProtocol(httpMethod: .get)
        do {
            let _: MockResponseModel = try await manager.request(emptyRequest)
            XCTFail("Expected request to fail, but it succeeded.")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
        
    }
    
    func testNetworkErrorDescription() throws {
        let error = NetworkError.authenticationError(description: "test")
        XCTAssertEqual(error.errorDescription, "test")
    }
}
