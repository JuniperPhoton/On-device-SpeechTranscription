//
//  TranscriptionService.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/28/25.
//
import Foundation
import Speech

protocol TranscriptionService {
    nonisolated func transcribeInternal(url: URL, locale: Locale) async throws -> String?
}

class TranscriptionServiceImpl: TranscriptionService {
    nonisolated func transcribeInternal(url: URL, locale: Locale) async throws -> String? {
        _ = url.startAccessingSecurityScopedResource()
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        let transcriber = SpeechTranscriber(locale: .init(identifier: locale.identifier), preset: .transcription)
        async let transcriptionFuture = try transcriber.results.reduce("") { partialResult, result in
            partialResult + result.text + "\n"
        }
        
        let analyzer = SpeechAnalyzer(modules: [transcriber])
        if let lastSample = try await analyzer.analyzeSequence(from: .init(forReading: url)) {
            try await analyzer.finalizeAndFinish(through: lastSample)
        } else {
            await analyzer.cancelAndFinishNow()
        }
        
        let result = try await transcriptionFuture
        let maps = result.characters.flatMap { String($0.utf8) }
        return maps.reduce("") { partialResult, c in
            partialResult + String(c)
        }.trimmingCharacters(in: .newlines)
    }
}
