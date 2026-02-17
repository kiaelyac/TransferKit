//
//  File.swift
//  TransferKit
//
//  Created by kiarash on 2/17/26.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
public protocol RequestStructurable {
    var url: String { get }
    var httpMethod: HTTPMethod { get }
    var httpHeaders: Codable { get }
    var httpBody: Codable? { get }
    var queryItems: Codable? { get }
}
public extension RequestStructurable {
    var queryItems: Codable? { nil }
    var httpBody: Codable? { nil }
}
public extension RequestStructurable {
    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = httpMethod.rawValue
        for headerItem in try httpHeaders.asDictionary() {
            urlRequest.setValue(headerItem.key, forHTTPHeaderField: headerItem.value as! String)
        }
        if let httpBody = httpBody {
            let jsonData = try JSONEncoder().encode(httpBody)
            urlRequest.httpBody = jsonData
        }
        if let queryItems = queryItems {
            let items = try queryItems.asDictionary().map { URLQueryItem(name: $0.key, value: $0.value as? String) }
            urlRequest.url?.append(queryItems: items)
        }
        return urlRequest
    }
}
