//
//  TranscriptionTaskStatusBadge.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import SwiftUI

struct TranscriptionTaskStatusBadge: View {
    var status: TranscriptionStatus
    var including: [TranscriptionStatus] = TranscriptionStatus.allCases
    
    var body: some View {
        Group {
            if including.contains(status) {
                switch status {
                case .pending:
                    Text("Pending")
                case .inProgress:
                    ProgressView().controlSize(.small)
                case .success:
                    Text("Done")
                case .failure:
                    Text("Failure")
                case .cancelled:
                    Text("Cancelled")
                }
            }
        }.padding(.horizontal, 8)
            .padding(.vertical, 4)
            .font(.footnote.bold())
            .glassEffect(.regular.tint(status.color), in: Capsule())
    }
}

#Preview {
    VStack {
        TranscriptionTaskStatusBadge(status: .pending)
        TranscriptionTaskStatusBadge(status: .inProgress)
        TranscriptionTaskStatusBadge(status: .success)
        TranscriptionTaskStatusBadge(status: .failure)
    }
}
