//
//  File.swift
//  TransferKit
//
//  Created by kiarash on 2/17/26.
//

import Foundation

public class Downloader {
    public init() { }
    public func download(for request: RequestStructurable) async throws -> AsyncThrowingStream<DownloadModel, Error> {
        let urlRequest = try request.asURLRequest()
        let (asyncBytes, response) = try await URLSession.shared.bytes(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return AsyncThrowingStream<DownloadModel, Error> { continuation in
            Task {
                let totalSize: Int64 = response.expectedContentLength
                let accumulator = ByteAccumulator(size: Int(totalSize))
                var iterator = asyncBytes.makeAsyncIterator()
                var item: DownloadModel = .init(progress: 0, data: nil)
                while !accumulator.checkCompleted() {
                    while !accumulator.isChunkCompleted, let byte = try await iterator.next() {
                    }
                }
                continuation.finish()
            }
        }
    }
}
