//
//  File.swift
//  TransferKit
//
//  Created by kiarash on 2/17/26.
//

import Foundation

class ByteAccumulator {
    let size: Int
    var bytes: [UInt8]
    var offset: Int = 0
    var data: Data { return Data(bytes[0..<offset]) }
    var chunkSize: Int { return max(1, Int(Double(size) / 40))}
    var counter: Int = -1
    var isChunkCompleted: Bool {
        return counter >= chunkSize
    }
    init(size: Int) {
        self.size = size
        self.bytes = Array(repeating: 0, count: size)
    }
    func append(_ byte: UInt8) {
        bytes[offset] = byte
        counter += 1
        offset += 1
    }
    func checkCompleted() -> Bool {
      defer { counter = 0 }
      return counter == 0
    }
    var progress: Double {
      Double(offset) / Double(size)
    }
}
