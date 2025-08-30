//  ContentView.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import SwiftUI
import UniformTypeIdentifiers

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
        } detail: {
            VStack {
                if let selectedTaskId, let task = transcriptionModel.getTaskBy(id: selectedTaskId) {
                    TranscriptionTaskDetailView(task: task)
                } else {
                    Group {
                        if transcriptionModel.isEmpty {
                            VStack {
                                Image(systemName: "document.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding(.bottom)
                                Text("Pick audio files from the sidebar or drop from other apps to get started.")
                            }
                        } else {
                            Text("Select an audio file to see details.")
                        }
                    }.padding()
                }
            }.navigationSplitViewColumnWidth(min: 300, ideal: 400)
        }.toolbar {
            toolbarItems
        }.navigationTitle("Speech Transcription")
            .onDrop(of: [.audio], isTargeted: $service.isDroppingFiles.animation(), perform: onDroppedFiles)
            .fileImporter(
                isPresented: $service.showFilePicker,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true
            ) { result in
                guard let urls = try? result.get() else { return }
                onPickedFiles(urls: urls)
            }
            .overlay {
                if service.isDroppingFiles {
                    FilesDroppingHintView()
                }
            }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            LocalePicker()
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
    
    private func onPickedFiles(urls: [URL]) {
        withAnimation {
            transcriptionModel.addTasks(urls: urls)
        }
    }
    
    private func onDroppedFiles(providers: [NSItemProvider]) -> Bool {
        Task {
            var files = [URL]()
            for provider in providers {
                if let url = await provider.tryLoadAsAudioFileRepresentation() {
                    files.append(url)
                }
            }
            onPickedFiles(urls: files)
        }
        return true
    }
}

#Preview {
    MainContentView()
}
