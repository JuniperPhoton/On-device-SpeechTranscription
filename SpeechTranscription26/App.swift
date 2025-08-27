//
//  SpeechTranscription26App.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//

import SwiftUI

@main
struct SpeechTranscription26App: App {
    @AppStorage(AppStorageKeys.fontSize.rawValue)
    private var fontSize: Double = TranscriptionFontStyle.defaultFontSize
    
    @AppStorage(AppStorageKeys.lineSpacing.rawValue)
    private var lineSpacing: Double = TranscriptionFontStyle.defaultLineSpacing
    
    @State private var filePickerService = FilePickerService()
    @State private var transcriptionModel = TranscriptionModel(service: TranscriptionServiceImpl())
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environment(filePickerService)
                .environment(transcriptionModel)
        }.defaultSize(width: 400, height: 300)
            .commands {
                CommandGroup(before: .newItem) {
                    Button {
                        filePickerService.showFilePicker = true
                    } label: {
                        Label("Pick Audio Files", systemImage: "document.badge.plus")
                    }
                    
                    Button {
                        transcriptionModel.removeAll()
                    } label: {
                        Label("Remove all files", systemImage: "trash")
                    }.disabled(transcriptionModel.isEmpty)
                    
                    Divider()
                }
                
                CommandMenu("Transcription") {
                    Button {
                        filePickerService.showFilePicker = true
                    } label: {
                        Label("Transcribe all", systemImage: "document.badge.plus")
                    }.disabled(transcriptionModel.isEmpty)
                    
                    Divider()
                    
                    LocalePicker()
                    
                    Divider()
                    
                    Button {
                        let newSize = fontSize + TranscriptionFontStyle.fontAlterStep
                        fontSize = min(newSize, TranscriptionFontStyle.maxFontSize)
                    } label: {
                        Label("Increase Font Size", systemImage: "textformat.size.larger")
                    }.disabled(fontSize >= TranscriptionFontStyle.maxFontSize)
                    
                    Button {
                        let newSize = fontSize - TranscriptionFontStyle.fontAlterStep
                        fontSize = max(newSize, TranscriptionFontStyle.minFontSize)
                    } label: {
                        Label("Decrease Font Size", systemImage: "textformat.size.smaller")
                    }.disabled(fontSize <= TranscriptionFontStyle.minFontSize)
                    
                    Button {
                        fontSize = TranscriptionFontStyle.defaultFontSize
                    } label: {
                        Label("Reset Font Size", systemImage: "arrow.trianglehead.clockwise")
                    }.disabled(fontSize == TranscriptionFontStyle.defaultFontSize)
                    
                    Divider()
                    
                    Button {
                        let newSize = lineSpacing + TranscriptionFontStyle.lineSpacingAlterStep
                        lineSpacing = min(newSize, TranscriptionFontStyle.maxLineSpacing)
                    } label: {
                        Label("Increase Line Spacing", systemImage: "arrow.up.and.line.horizontal.and.arrow.down")
                    }.disabled(lineSpacing >= TranscriptionFontStyle.maxLineSpacing)
                    
                    Button {
                        let newSize = lineSpacing - TranscriptionFontStyle.lineSpacingAlterStep
                        lineSpacing = max(newSize, TranscriptionFontStyle.minLineSpacing)
                    } label: {
                        Label("Decrease Line Spacing", systemImage: "arrow.down.and.line.horizontal.and.arrow.up")
                    }.disabled(lineSpacing <= TranscriptionFontStyle.minLineSpacing)
                    
                    Button {
                        lineSpacing = TranscriptionFontStyle.defaultLineSpacing
                    } label: {
                        Label("Reset Line Spacing", systemImage: "arrow.trianglehead.clockwise")
                    }.disabled(lineSpacing == TranscriptionFontStyle.defaultLineSpacing)
                }
            }
    }
}
