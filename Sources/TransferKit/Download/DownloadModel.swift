//
//  File.swift
//  TransferKit
//
//  Created by kiarash on 2/19/26.
//

import Foundation

public struct DownloadModel: Sendable {
   public var progress: CGFloat
   public var data: Data?
    public init(progress: CGFloat, data: Data? = nil) {
        self.progress = progress
        self.data = data
    }
}
