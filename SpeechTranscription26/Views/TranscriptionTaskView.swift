//
//  TranscriptionTaskView.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import SwiftUI
import PhotonUtilityView

struct TranscriptionTaskDetailView: View {
    var task: TranscriptionTask
    
    var body: some View {
        VStack {
            HStack {
                Text("\(task.displayName)")
                    .font(.title3.bold())
                
                TranscriptionTaskStatusBadge(
                    status: task.status,
                    including: [.failure, .inProgress, .pending, .cancelled]
                )
                
                Spacer()
                
                if let result = task.result, !result.isEmpty {
                    CopyButton(text: result)
                }
            }
            .font(.body.bold())
            
            if let result = task.result, !result.isEmpty {
                Divider()
                TranscriptionTextView(text: result)
            } else {
                Spacer()
            }
        }.geometryGroup()
            .frame(maxWidth: .infinity)
            .textSelection(.enabled)
            .padding()
            .animation(.default, value: task.result)
            .animation(.default, value: task.status)
    }
}

private struct CopyButton: View {
    @Environment(\.copyToPasteBoard) private var copyToPasteBoard
    
    var text: String
    
    @State private var copied = false
    
    var body: some View {
        Button {
            if copied { return }
            Task {
                await copyToPasteBoardInternal(result: text)
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "document.on.document")
                .frame(minWidth: 50, minHeight: 30)
                .contentShape(Rectangle())
                .symbolEffect(.bounce, value: copied)
        }
        .foregroundStyle(copied ? .white : .primary)
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(copied ? .accent : .clear).interactive())
        .animation(.default, value: copied)
    }
    
    private func copyToPasteBoardInternal(result: String) async {
        copyToPasteBoard(text: result)
        copied = true
        try? await Task.sleep(for: .seconds(1))
        copied = false
    }
}

private struct TranscriptionTextView: View {
    @AppStorage(AppStorageKeys.fontSize.rawValue)
    private var fontSize: Double = TranscriptionFontStyle.defaultFontSize
    
    @AppStorage(AppStorageKeys.lineSpacing.rawValue)
    private var lineSpacing: Double = TranscriptionFontStyle.defaultLineSpacing
    
    var text: String
    
    var body: some View {
        ScrollableTextViewCompat(
            text: text,
            style: .init(
                fontStyle: .init(
                    font: .messageFont(ofSize: fontSize),
                    lineSpacing: lineSpacing
                ),
                behaviorStyle: .init(autoScrollToBottom: false)
            )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
