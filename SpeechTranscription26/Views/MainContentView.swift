//
//  ContentView.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import SwiftUI
import UniformTypeIdentifiers
import Speech

struct MainContentView: View {
    @Environment(FilePickerService.self) private var filePickerService
    @Environment(TranscriptionModel.self) private var transcriptionModel
    
    @State private var selectedTaskId: String? = nil
    
    @AppStorage(AppStorageKeys.locale.rawValue)
    private var locale: Locale = .english
    
    var body: some View {
        @Bindable var service = filePickerService
        
        NavigationSplitView {
            SideBarView(selectedTaskId: $selectedTaskId)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
                .navigationTitle("Speech Transcription")
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarItems
                }
#endif
        } detail: {
            if let selectedTaskId, let task = transcriptionModel.getTaskBy(id: selectedTaskId) {
                TranscriptionTaskDetailView(task: task)
                    .navigationSplitViewColumnWidth(min: 300, ideal: 400)
            }
        }.toolbar {
            toolbarItems
        }.navigationTitle("Speech Transcription")
            .fileImporter(
                isPresented: $service.showFilePicker,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true
            ) { result in
                guard let urls = try? result.get() else { return }
                onPickedFiles(urls: urls)
            }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
#if os(macOS)
                localePicker
#else
                Menu {
                    localePicker
                } label: {
                    Image(systemName: "globe")
                }
#endif
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            if !transcriptionModel.tasks.isEmpty {
                Button {
                    transcriptionModel.startTranscribing(locale: locale)
                } label: {
                    if transcriptionModel.isRunningTask {
                        HStack {
                            Text("Transcribing...")
                            ProgressView().controlSize(.small).tint(.white)
                        }
                    } else {
                        Label("Transcribe all", systemImage: "play.fill")
                            .labelStyle(.titleAndIcon)
                    }
                }.buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var localePicker: some View {
        LocalePicker()
    }
    
    private func onPickedFiles(urls: [URL]) {
        withAnimation {
            transcriptionModel.addTasks(urls: urls)
        }
    }
}

private struct ToolbarDivider: View {
    var body: some View {
#if os(iOS)
        Divider()
#else
        EmptyView()
#endif
    }
}

extension View {
    func glassyButtonLabel(tintColor: Color? = nil, shape: some Shape = Capsule()) -> some View {
        self.labelStyle(.titleAndIcon)
            .padding(12)
            .frame(maxWidth: .infinity)
            .contentShape(Capsule())
            .glassEffect(.regular.interactive().tint(tintColor), in: shape)
    }
}

#Preview {
    MainContentView()
}
