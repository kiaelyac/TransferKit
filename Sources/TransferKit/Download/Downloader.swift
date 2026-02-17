//
//  File.swift
//  TransferKit
//
//  Created by kiarash on 2/17/26.
//

import Foundation

public class Downloader {
    func download(for request: RequestStructurable) async throws -> AsyncThrowingStream<Data, Error> {
        let urlRequest = try request.asURLRequest()
        let (data, response) = try await URLSession.shared.bytes(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return AsyncThrowingStream<Data, Error> { continuation in
            Task {
                let accumulator = ByteAccumulator(size: Int(response.expectedContentLength))
                while !accumulator.checkCompleted() {
                    while !accumulator.isChunkCompleted {
                        for try await byte in data {
                            accumulator.append(byte)
                            continuation.yield(accumulator.data)
                        }
                    }
                }
                continuation.yield(accumulator.data)
            }
        }
    }
}
