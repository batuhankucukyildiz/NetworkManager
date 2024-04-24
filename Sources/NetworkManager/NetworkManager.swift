//  NetworkManager.swift
//
//  Created by Batuhan Kucukyildiz on 15.01.2024.
//

import Foundation

final public class NetworkManager {
    private init() {}
    public static let shared: NetworkManager = NetworkManager() // Singleton Pattern
    private let jsonDecoder = JSONDecoder()
    
    public func request<T: Decodable>(_ endpoint: EndpointProtocol, completion: @escaping (Result<T, Error>) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: endpoint.request()) { [weak self] (data, response, error) in
            guard let self = self else { return }
            // MARK: Error Handle
            if let error = error {
                #if DEBUG
                print("Error \(error)")
                #endif
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            // MARK: Response Handle
            if let response = response as? HTTPURLResponse {
                let handleResponse = self.handleNetworkRequest(response: response)
                switch handleResponse {
                case .success(let callbackResponse):
                    #if DEBUG
                    print("\(callbackResponse)")
                    #endif
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            // MARK: Data Handle
            if let data = data {
                do {
                    let jsonData = try self.jsonDecoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(jsonData))
                    }
                }
                catch let error {
                    #if DEBUG
                    //print("Error \(error)")
                    #endif
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    private func handleNetworkRequest(response: HTTPURLResponse) -> Result<String, NetworkError> {
        switch response.statusCode {
        case 200...299: return .success("Request Success")
        case 401...500: return .failure(NetworkError.authenticationError(description: "Authentication Error"))
        case 501...599: return .failure(NetworkError.badRequest(description: "Bad Request"))
        default: return .failure(NetworkError.networkError(description: "Network Error"))
        }
    }
}
