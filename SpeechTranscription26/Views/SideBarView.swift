//
//  SideBarView.swift
//  SpeechTranscription26
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
                        TranscriptionTaskItemView(task: task)
                            .foregroundStyle(selectedTaskId == task.id ? .white : .primary)
                            .glassyButtonLabel(
                                tintColor: selectedTaskId == task.id ? Color.accentColor : nil,
                                shape: RoundedRectangle(cornerRadius: 12)
                            )
                    }.buttonStyle(.plain)
                }
            }.padding([.horizontal, .bottom])
        }.safeAreaInset(edge: .top) {
            HStack {
                Button {
                    filePickerService.showFilePicker = true
                } label: {
                    Label("Pick Audio Files", systemImage: "document.badge.plus")
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
        }
    }
}
