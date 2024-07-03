//  NetworkManager.swift
//
//  Created by Batuhan Kucukyildiz on 15.01.2024.
//

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
            let callbackResponse = try await handleNetworkRequest(response: httpResponse)
            #if DEBUG
            print("\(callbackResponse)")
            #endif
        } catch {
            throw error
        }
        
        do {
            return try decodeJSON(data: data)
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

    // JSON verisini decode etme fonksiyonu
    private func decodeJSON<T: Decodable>(data: Data) throws -> T {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        if let jsonArray = jsonObject as? [[String: Any]] {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
            let decodedData = try self.jsonDecoder.decode([T].self, from: jsonData)
            guard let firstElement = decodedData.first else {
                throw NetworkError.invalidResponse(description: "No elements found in array")
            }
            return firstElement
        } else if let jsonDict = jsonObject as? [String: Any] {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict)
            let decodedData = try self.jsonDecoder.decode(T.self, from: jsonData)
            return decodedData
        } else {
            throw NetworkError.invalidResponse(description: "Unexpected JSON format")
        }
    }
}
