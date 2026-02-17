//
//  File.swift
//  TransferKit
//
//  Created by kiarash on 2/17/26.
//
import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
    }
}
