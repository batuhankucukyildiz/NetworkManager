//
//  File.swift
//  
//
//  Created by Batuhan Küçükyıldız on 10.08.2024.
//

import Foundation

public struct ErrorResponse: Decodable, Error {
    let code: String
    let status: Int
    let priority: Int
    let success: Bool
    let message: String
}
