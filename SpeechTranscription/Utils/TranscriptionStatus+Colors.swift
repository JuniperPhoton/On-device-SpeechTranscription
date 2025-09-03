//
//  TranscriptionStatus+Colors.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 9/2/25.
//
import Foundation
import SwiftUI

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
            return .red.opacity(0.2)
        case .cancelled:
            return .yellow.opacity(0.2)
        }
    }
}
