//
//  SpeechTranscriptionApp.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/27/25.
//

import SwiftUI

@main
struct SpeechTranscriptionApp: App {
    @AppStorage(AppStorageKeys.fontSize.rawValue)
    private var fontSize: Double = TranscriptionFontStyle.defaultFontSize
    
    @AppStorage(AppStorageKeys.lineSpacing.rawValue)
    private var lineSpacing: Double = TranscriptionFontStyle.defaultLineSpacing
    
    @State private var filePickerService = FilePickerService()
    @State private var transcriptionModel = TranscriptionModel(service: TranscriptionServiceImpl())
    @State private var localesModel = AppLocalesModel()
    
    var body: some Scene {
        WindowGroup {
            if transcriptionModel.isAvailable {
                MainContentView()
            } else {
                Text("SpeechTranscriber reports that the feature is unavailable on this device.")
                    .frame(minWidth: 300)
            }
        }.defaultSize(width: 400, height: 300)
            .commands { commands }
            .environment(filePickerService)
            .environment(transcriptionModel)
            .environment(localesModel)
        
        Settings {
            SettingsView()
                .frame(minWidth: 600, minHeight: 400)
        }.defaultPosition(.center)
            .defaultSize(width: 600, height: 400)
            .environment(localesModel)
    }
    
    @CommandsBuilder
    private var commands: some Commands {
        CommandGroup(before: .newItem) {
            Button {
                filePickerService.showFilePicker = true
            } label: {
                Label("Pick Audio Files / Folder", systemImage: "document.badge.plus")
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
            
            LocalePicker().environment(localesModel)
            
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
