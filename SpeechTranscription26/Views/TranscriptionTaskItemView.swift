//
//  TranscriptionTaskItemView.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/28/25.
//
import SwiftUI

struct TranscriptionTaskItemView: View {
    var task: TranscriptionTask
    var isSelected: Bool
    
    var body: some View {
        VStack {
            TranscriptionTaskStatusBadge(status: task.status, including: [.failure, .cancelled])
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Group {
                    if task.status == .inProgress {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "play.circle")
                    }
                }.frame(width: 24, height: 24)
                
                Text("\(task.file.lastPathComponent)")
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.geometryGroup()
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(isSelected ? .white : .primary)
        .glassyButtonLabel(
            tintColor: isSelected ? Color.accentColor : nil,
            shape: RoundedRectangle(cornerRadius: 12)
        )
        .animation(.default, value: task.status)
        .animation(.default, value: isSelected)
    }
}
