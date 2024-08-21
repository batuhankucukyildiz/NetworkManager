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
            if response.statusCode == 406 {
                let errorResponse = try? JSONDecoder().decode(RatingErrorResponse.self, from: data)
                let code = errorResponse?.error.code ?? 0
                let remainingTries = errorResponse?.remainingTries ?? 3
                throw NetworkError.acceptableResponse(code: code, remainingTries: remainingTries)
            }
            else {
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                let code = errorResponse?.code ?? 0
                throw NetworkError.badRequest(code: code)
            }
        case 500...599:
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            let code = errorResponse?.code ?? 0
            throw NetworkError.badRequest(code: code)
        default:
            throw NetworkError.networkError(code: 500)
        }
    }
}
