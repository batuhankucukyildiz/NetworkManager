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
    case acceptableResponse(code: Int, remainingTries: Int)
    public var errorDescription: String? {
        switch self {
        case .jsonDecoderError(let description),
             .invalidResponse(let description):
            return description
        case .authenticationError(let code),
             .badRequest(let code),
             .networkError(let code):
            return "\(code)"
        case .acceptableResponse(let code, let remainingTries):
            return "\(code) \(remainingTries)"
        }
    }
    public func parseAcceptableResponse() -> (code: Int, remainingTries: Int)? {
        if case .acceptableResponse(let code, let remainingTries) = self {
            return (code, remainingTries)
        }
        return nil
    }
}
