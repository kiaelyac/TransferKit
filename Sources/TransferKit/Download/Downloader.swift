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
                while !accumulator.checkCompleted() {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let previousDataCount = accumulator.data.count
                    while !accumulator.isChunkCompleted, let byte = try await iterator.next() {
                        accumulator.append(byte)
                    }
                    let endTime = CFAbsoluteTimeGetCurrent()
                    let timeInterval = endTime - startTime
                    let currentDataCount = accumulator.data.count
                    let receivedDataCount = currentDataCount - previousDataCount
                    guard timeInterval > 0 else { continue }
                    let bytesPerSecond = Double(receivedDataCount) / timeInterval
                    let remainingBytes = Double(accumulator.remainingSize)
                    let remainingTime = remainingBytes / bytesPerSecond
                    continuation.yield(.init(progress: accumulator.progress, data: accumulator.data, downloadSpeed: remainingTime.rounded()))
                }
                continuation.finish()
            }
        }
    }
}
