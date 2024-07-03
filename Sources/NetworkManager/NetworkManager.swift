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
            let callbackResponse = try await handleNetworkRequest(response: httpResponse)
            #if DEBUG
            print("\(callbackResponse)")
            #endif
        } catch {
            throw error
        }
        
        do {
            let jsonData = try self.jsonDecoder.decode(T.self, from: data)
            return jsonData
        } catch {
            throw error
        }
    }

    
    private func handleNetworkRequest(response: HTTPURLResponse) async throws -> String {
        switch response.statusCode {
        case 200...299:
            return "Request Success"
        case 401...500:
            throw NetworkError.authenticationError(description: "Authentication Error")
        case 501...599:
            throw NetworkError.badRequest(description: "Bad Request")
        default:
            throw NetworkError.networkError(description: "Network Error")
        }
    }

}
