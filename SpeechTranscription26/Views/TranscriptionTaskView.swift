//
//  TranscriptionTaskView.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import SwiftUI
import PhotonUtilityView

struct TranscriptionTaskDetailView: View {
    @AppStorage(AppStorageKeys.fontSize.rawValue)
    private var fontSize: Double = TranscriptionFontStyle.defaultFontSize
    
    @AppStorage(AppStorageKeys.lineSpacing.rawValue)
    private var lineSpacing: Double = TranscriptionFontStyle.defaultLineSpacing
    
    var task: TranscriptionTask
    
    @State private var copied = false
    
    var body: some View {
        VStack {
            HStack {
                Text("\(task.file.lastPathComponent)")
                    .font(.title3.bold())
                
                TranscriptionTaskStatusBadge(status: task.status, including: [.failure, .inProgress, .pending])
                
                Spacer()
                
                if let result = task.result, !result.isEmpty {
                    Button {
                        Task {
                            await copyToPasteBoard(result: result)
                        }
                    } label: {
                        Image(systemName: copied ? "checkmark" : "document.on.document")
                            .frame(minWidth: 50, minHeight: 30)
                            .contentShape(Rectangle())
                    }
                    .foregroundStyle(copied ? .white : .primary)
                    .buttonStyle(.plain)
                    .glassEffect(.regular.tint(copied ? .accent : .clear))
                }
            }
            .font(.body.bold())
            
            if let result = task.result, !result.isEmpty {
                Divider()
                                
                ScrollableTextViewCompat(
                    text: result,
                    style: .init(
                        fontStyle: .init(
                            font: .systemFont(ofSize: fontSize),
                            lineSpacing: lineSpacing
                        ),
                        behaviorStyle: .init(autoScrollToBottom: false)
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer()
            }
        }.geometryGroup()
            .frame(maxWidth: .infinity)
            .textSelection(.enabled)
            .animation(.default, value: copied)
            .padding()
            .animation(.default, value: task.result)
            .animation(.default, value: task.status)
    }
    
    private func copyToPasteBoard(result: String) async {
#if os(iOS)
        let pasteboard = UIPasteboard.general
        pasteboard.string = result
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(result, forType: .string)
#endif
        copied = true
        try? await Task.sleep(for: .seconds(1))
        copied = false
    }
}
