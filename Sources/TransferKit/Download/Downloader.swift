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
                let accumulator = ByteAccumulator(size: Int(response.expectedContentLength))
                var iterator = asyncBytes.makeAsyncIterator()
                var item: DownloadModel = .init(progress: 0, data: nil)
                while !accumulator.checkCompleted() {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    while !accumulator.isChunkCompleted, let byte = try await iterator.next() {
                        accumulator.append(byte)
                        item.data = accumulator.data
                        item.progress = accumulator.progress
                        continuation.yield(item)
                    }
                    let endTime = CFAbsoluteTimeGetCurrent()
                    let timeInterval: TimeInterval = endTime - startTime
                    let receivedDataCount = accumulator.data.count
                    let speed = Double(receivedDataCount) / timeInterval 
                    item.downloadSpeed = speed

                }
                continuation.finish()
            }
        }
    }
}
