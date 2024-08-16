//
//  File.swift
//  
//
//  Created by Batuhan Küçükyıldız on 24.04.2024.
//

import Foundation

public enum NetworkError: LocalizedError {
    case jsonDecoderError(description: String)
    case authenticationError(code: Int)
    case badRequest(code: Int)
    case networkError(code: Int)
    case invalidResponse(description: String)

    public var errorDescription: String? {
        switch self {
        case .jsonDecoderError(let description),
             .invalidResponse(let description):
            return description
        case .authenticationError(let code),
             .badRequest(let code),
             .networkError(let code):
            return "Error code: \(code)"
        }
    }
}
