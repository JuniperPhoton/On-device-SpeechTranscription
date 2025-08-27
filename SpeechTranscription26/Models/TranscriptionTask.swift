//
//  TranscriptionTask.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import SwiftUI

enum TranscriptionStatus: Hashable, CaseIterable {
    case pending
    case inProgress
    case success
    case failure
}

extension TranscriptionStatus {
    var color: Color {
        switch self {
        case .pending:
            return .gray.opacity(0.1)
        case .inProgress:
            return .clear
        case .success:
            return .accent.opacity(0.2)
        case .failure:
            return .yellow
        }
    }
}

@Observable
class TranscriptionTask: Identifiable, Hashable {
    static func == (lhs: TranscriptionTask, rhs: TranscriptionTask) -> Bool {
        lhs.id == rhs.id
    }
    
    var file: URL
    var result: String?
    var status: TranscriptionStatus = .pending
    
    var id: String {
        file.absoluteString
    }
    
    init(file: URL, result: String? = nil) {
        self.file = file
        self.result = result
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
