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
        
        // Yanıtın Content-Type'ının "image" ile başlayıp başlamadığını kontrol et
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
           contentType.hasPrefix("image") {
            if T.self == UIImage.self {
                // Eğer T UIImage ise, veriyi UIImage olarak döndür
                guard let image = UIImage(data: data) else {
                    throw NetworkError.invalidResponse(description: "Failed to decode image data")
                }
                return image as! T
            } else {
                throw NetworkError.invalidResponse(description: "Expected image but found other data type")
            }
        }
        
        // Eğer JSON ise, JSON yanıtını çözümleyin
        do {
            let jsonData = try self.jsonDecoder.decode(T.self, from: data)
            return jsonData
        } catch {
            throw NetworkError.invalidResponse(description: "Failed to decode JSON response")
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
            } else {
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
