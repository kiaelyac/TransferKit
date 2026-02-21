//
//  File.swift
//  TransferKit
//
//  Created by kiarash on 2/19/26.
//

import Foundation

public struct DownloadModel: Identifiable, Sendable {
    public var id: UUID = UUID()
    public var progress: CGFloat
    public var data: Data?
    public var downloadSpeed: Double?
    public init(progress: CGFloat, data: Data? = nil) {
        self.progress = progress
        self.data = data
    }
}
