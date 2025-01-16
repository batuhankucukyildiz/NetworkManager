import UIKit

final public class NetworkManager {
    private init() {}
    public static let shared: NetworkManager = NetworkManager() // Singleton Pattern
    private let jsonDecoder = JSONDecoder()
    
    public func request<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: endpoint.request())
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(description: "Invalid Response")
        }
        
        do {
            let callbackResponse = try await handleNetworkRequest(response: httpResponse, data: data)
            #if DEBUG
            print("callbackResponse: \(callbackResponse)")
            #endif
        } catch {
            throw error
        }
        
        do {
            print("Response Data: \(data)")
            let jsonData = try self.jsonDecoder.decode(T.self, from: data)
            return jsonData
        } catch {
            throw error
        }
    }
    
    public func requestImage(_ endpoint: EndpointProtocol) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(for: endpoint.request())
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(description: "Invalid Response")
        }
        
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
           contentType.hasPrefix("image") {
            if let image = UIImage(data: data) {
                return image
            } else {
                throw NetworkError.invalidResponse(description: "Expected image but found other data type")
            }
        } else {
            throw NetworkError.invalidResponse(description: "Expected image but received other content type")
        }
    }

    private func handleNetworkRequest(response: HTTPURLResponse, data: Data) async throws -> String {
        switch response.statusCode {
        case 200...299:
            return "Request Success"
        case 400...599:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw errorResponse
            } else {
                throw NetworkError.invalidResponse(description: "Unable to decode error response")
            }
        default:
            throw NetworkError.networkError(code: 500)
        }
    }

}
