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
    
    private let service: any TranscriptionService
    
    var isAvailable: Bool {
        type(of: service).isAvailable
    }
    
    var isRunningTask: Bool {
        transcriptionTask != nil
    }
    
    var isEmpty: Bool {
        tasks.isEmpty
    }
    
    init(service: any TranscriptionService) {
        self.service = service
    }
    
    func getTaskBy(id: String) -> TranscriptionTask? {
        tasks.first(where: { $0.id == id })
    }
    
    func removeTask(of id: String) {
        tasks.removeAll(where: { $0.id == id })
    }
    
    func addTasks(urls: [URL]) {
        for url in urls {
            if isFolder(url: url) {
                let audioFiles = listAudioFilesInFolder(url: url)
                for file in audioFiles {
                    addTask(of: file, referencingSourceURL: url)
                }
            } else {
                addTask(of: url, referencingSourceURL: url)
            }
        }
    }
    
    func startTranscribing(locale: AppLocale) {
        if transcriptionTask != nil {
            cancel()
        } else {
            let pendingTasks = tasks.filter({ $0.status == .pending || $0.status == .failure || $0.status == .cancelled })
            if pendingTasks.isEmpty {
                return
            }
            
            transcriptionTask = Task {
                defer {
                    transcriptionTask = nil
                }
                await transcribeAudioFile(locale: locale, tasks: tasks)
            }
        }
    }
    
    private func addTask(of audioFile: URL, referencingSourceURL: URL) {
        let source = TranscriptionTaskSource(referencingSourceURL: referencingSourceURL, fileURL: audioFile)
        if tasks.contains(where: { $0.source == source }) {
            return
        }
        tasks.append(TranscriptionTask(source: source))
    }
    
    private func listAudioFilesInFolder(url: URL) -> [URL] {
        _ = url.startAccessingSecurityScopedResource()
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .typeIdentifierKey]
        ) else {
            return []
        }
        
        let audioFiles = contents.filter { fileURL in
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.typeIdentifierKey]) {
                if let typeIdentifier = resourceValues.typeIdentifier, let utType = UTType(typeIdentifier) {
                    return utType.conforms(to: .audio)
                }
            }
            return false
        }
        
        return audioFiles
    }
    
    private func isFolder(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    private func transcribeAudioFile(locale: AppLocale, tasks: [TranscriptionTask]) async {
        await withTaskGroup { group in
            for task in tasks {
                _ = group.addTaskUnlessCancelled { @MainActor in
                    await self.transcribe(task: task, locale: locale)
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
    
    private func transcribe(task: TranscriptionTask, locale: AppLocale) async {
        do {
            task.result = nil
            task.status = .inProgress
            let results = try await self.service.transcribeStream(source: task.source, locale: locale)
            
            for try await result in results {
                if Task.isCancelled {
                    throw CancellationError()
                }
                task.result = (task.result ?? "") + result + "\n"
            }
            
            if Task.isCancelled {
                throw CancellationError()
            }
            
            task.result = task.result?.trimmingCharacters(in: .whitespacesAndNewlines)
            task.status = .success
        } catch is CancellationError {
            task.status = .cancelled
            task.result = task.result?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            task.result = nil
            task.status = .failure
            AppLogger.defaultLogger.warning("Transcription failed: \(error)")
        }
    }
}
