//
//  TranscriptionModel.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/28/25.
//
import SwiftUI
import Speech
import OSLog

@MainActor
@Observable
class TranscriptionModel {
    private(set) var tasks: [TranscriptionTask] = []
    private(set) var transcriptionTask: Task<Void, Never>? = nil
    
    private let service: TranscriptionService
    
    var isAvailable: Bool {
        type(of: service).isAvailable
    }
    
    var isRunningTask: Bool {
        transcriptionTask != nil
    }
    
    var isEmpty: Bool {
        tasks.isEmpty
    }
    
    init(service: TranscriptionService) {
        self.service = service
    }
    
    func getTaskBy(id: String) -> TranscriptionTask? {
        tasks.first(where: { $0.id == id })
    }
    
    func addTasks(urls: [URL]) {
        for url in urls {
            if tasks.contains(where: { $0.file == url }) {
                continue
            }
            tasks.append(TranscriptionTask(file: url))
        }
    }
    
    func startTranscribing(locale: AppLocale) {
        if transcriptionTask != nil {
            cancel()
        } else {
            transcriptionTask = Task {
                await transcribeAudioFile(locale: locale)
                transcriptionTask = nil
            }
        }
    }
    
    private func transcribeAudioFile(locale: AppLocale) async {
        await withTaskGroup { group in
            for task in tasks.filter({ $0.status == .pending || $0.status == .failure }) {
                _ = group.addTaskUnlessCancelled { @MainActor in
                    do {
                        task.status = .inProgress
                        let result = try await self.service.transcribe(url: task.file, locale: locale) ?? ""
                        task.result = result
                        task.status = .success
                    } catch {
                        task.status = .failure
                        AppLogger.defaultLogger.warning("Transcription failed: \(error)")
                    }
                }
            }
        }
    }
    
    func removeAll() {
        cancel()
        tasks.removeAll()
    }
    
    func cancel() {
        transcriptionTask?.cancel()
        transcriptionTask = nil
    }
}
