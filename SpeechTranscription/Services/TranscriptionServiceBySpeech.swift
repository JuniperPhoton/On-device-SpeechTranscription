//
//  TranscriptionServiceSpeechImpl.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 9/9/25.
//
import Speech

class TranscriptionServiceBySpeech: TranscriptionService {
    static var isAvailable: Bool { SpeechTranscriber.isAvailable }
    static var shouldCheckAvailibilityAsync: Bool { false }
    static var supportsParallelTasks: Bool { true }
    
    nonisolated func transcribeStream(
        source: TranscriptionTaskSource,
        locale: AppLocale,
        options: [String: Any]
    ) async throws -> some AsyncSequence<String, any Error> {
        try await source.accessing { url in
            let transcriber = SpeechTranscriber(
                locale: Locale(identifier: locale.identifier),
                preset: .transcription
            )

            let analyzer = SpeechAnalyzer(modules: [transcriber])
            try await analyzer.start(inputAudioFile: .init(forReading: url), finishAfterFile: true)

            return transcriber.results.filter { $0.isFinal }.map { result in
                result.text.characters.flatMap { String($0.utf8) }.reduce("") { partialResult, c in
                    partialResult + String(c)
                }
            }
        }
    }
}
