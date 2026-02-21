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

        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let totalSize = response.expectedContentLength

        return AsyncThrowingStream { continuation in
            Task {
                var received: Int64 = 0
                var buffer = Data()
                buffer.reserveCapacity(Int(totalSize))

                var iterator = asyncBytes.makeAsyncIterator()

                while let chunk = try? await iterator.next() {

                    buffer.append(chunk)
                    received += Int64(Data([chunk]).count)

                    let progress = Double(received) / Double(totalSize)

                    continuation.yield(
                        DownloadModel(
                            progress: progress,
                            data: nil   // ❗ don’t send full data every time
                        )
                    )
                }

                continuation.yield(
                    DownloadModel(
                        progress: 1.0,
                        data: buffer
                    )
                )

                continuation.finish()
            }
        }
    }
}
