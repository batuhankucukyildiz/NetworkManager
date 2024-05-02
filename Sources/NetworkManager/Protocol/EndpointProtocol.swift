//
//  EndpointProtocol.swift
//
//
//  Created by Batuhan Küçükyıldız on 24.04.2024.
//

import Foundation

public protocol EndpointProtocol {
    var baseUrl: String { get }
    var path: String { get }
    var httpMethod: HttpMethods { get }
    var params: [String: Any]? { get }
    var headers: [String: Any]? { get }
    func request() -> URLRequest
}
