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
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let previousDataCount = accumulator.data.count
                    while !accumulator.isChunkCompleted, let byte = try await iterator.next() {
                        accumulator.append(byte)
                        item.data = accumulator.data
                        item.progress = accumulator.progress
                        continuation.yield(item)
                    }
                    let endTime = CFAbsoluteTimeGetCurrent()
                    let timeInterval: TimeInterval = endTime - startTime
                    let currentDataCount = accumulator.data.count
                    let receivedDataCount = currentDataCount - previousDataCount
                    let speed = Double(receivedDataCount) / timeInterval
                    let value = ((speed / 1024) / 1024) * 8
                    let remainingTime: TimeInterval = (Double(accumulator.remainingSize) * value) / Double(receivedDataCount)
                    item.downloadSpeed = remainingTime.rounded()
                }
                continuation.finish()
            }
        }
    }
}
