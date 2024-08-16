import Foundation
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
            print("\(callbackResponse)")
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

    private func handleNetworkRequest(response: HTTPURLResponse, data: Data) async throws -> String {
        switch response.statusCode {
        case 200...299:
            return "Request Success"
        case 401...499:
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            let code = errorResponse?.code ?? 0
            throw NetworkError.authenticationError(description: String(code))
        case 500...599:
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            let code = errorResponse?.code ?? 0
            throw NetworkError.badRequest(description: String(code))
        default:
            throw NetworkError.networkError(description: "Network Error")
        }
    }
}
