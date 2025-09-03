//
//  SideBarView.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/28/25.
//
import SwiftUI

struct SideBarView: View {
    @Environment(FilePickerService.self) private var filePickerService
    @Environment(TranscriptionModel.self) private var transcriptionModel
    
    @Binding var selectedTaskId: String?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(transcriptionModel.tasks) { task in
                    Button {
                        withAnimation {
                            selectedTaskId = task.id
                        }
                    } label: {
                        TranscriptionTaskItemView(
                            task: task,
                            isSelected: selectedTaskId == task.id
                        )
                    }.buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                openInFinder(task: task)
                            } label: {
                                Label("Open in Finder", systemImage: "arrow.up.right")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                transcriptionModel.removeTask(of: task.id)
                            } label: {
                                Label("Remove from list", systemImage: "trash")
                            }.disabled(task.status == .inProgress)
                        }
                }
            }.padding([.horizontal, .bottom])
        }.safeAreaInset(edge: .top) {
            HStack {
                Button {
                    filePickerService.showFilePicker = true
                } label: {
                    Label("Pick Audio Files / Folder", systemImage: "document.badge.plus")
                        .glassyButtonLabel()
                }
                .buttonStyle(.plain)
                
                if !transcriptionModel.tasks.isEmpty {
                    Button {
                        withAnimation {
                            transcriptionModel.removeAll()
                            selectedTaskId = nil
                        }
                    } label: {
                        Label("Remove all", systemImage: "trash")
                            .labelStyle(.iconOnly)
                            .padding(12)
                            .contentShape(Circle())
                            .foregroundStyle(.red)
                            .glassEffect(.regular, in: Circle())
                    }.buttonStyle(.plain)
                }
            }.buttonStyle(.glass).padding(.horizontal)
        }.animation(.default, value: transcriptionModel.tasks.count)
    }
    
    private func openInFinder(task: TranscriptionTask) {
        let fileURL = task.source.fileURL
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
}
