//
//  TranscriptionTask.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/27/25.
//
import SwiftUI

enum TranscriptionStatus: Hashable, CaseIterable {
    case pending
    case inProgress
    case success
    case failure
    case cancelled
}

@Observable
class TranscriptionTask: Identifiable, Hashable {
    static func == (lhs: TranscriptionTask, rhs: TranscriptionTask) -> Bool {
        lhs.id == rhs.id
    }
    
    var source: TranscriptionTaskSource
    var result: String?
    var status: TranscriptionStatus = .pending
    
    var id: String {
        source.fileURL.absoluteString
    }
    
    var displayName: String {
        source.fileURL.lastPathComponent
    }
    
    init(source: TranscriptionTaskSource, result: String? = nil) {
        self.source = source
        self.result = result
    }
    
    func clearResult() {
        result = nil
        status = .pending
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
