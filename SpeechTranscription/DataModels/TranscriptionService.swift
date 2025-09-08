//
//  TranscriptionService.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/28/25.
//
import Foundation
import OSLog
import Speech

protocol TranscriptionService {
    associatedtype AsyncSequenceType: AsyncSequence<String, any Error>
    static var isAvailable: Bool { get }
    nonisolated func transcribeStream(source: TranscriptionTaskSource, locale: AppLocale) async throws -> AsyncSequenceType
}

extension TranscriptionService {
    nonisolated func transcribe(source: TranscriptionTaskSource, locale: AppLocale) async throws -> String? {
        let stream = try await transcribeStream(source: source, locale: locale)
        return try await stream.reduce(into: "") { partialResult, c in
            partialResult = partialResult + c + "\n"
        }.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

class TranscriptionServiceStub: TranscriptionService {
    static var isAvailable: Bool {
        false
    }
    
    nonisolated func transcribeStream(
        source: TranscriptionTaskSource,
        locale: AppLocale
    ) async throws -> AsyncThrowingStream<String, any Error> {
        throw NSError(
            domain: "TranscriptionServiceStub",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Transcription service is not available."]
        )
    }
}

class TranscriptionServiceImpl: TranscriptionService {
    static var isAvailable: Bool {
        SpeechTranscriber.isAvailable
    }
    
    nonisolated func transcribeStream(
        source: TranscriptionTaskSource,
        locale: AppLocale
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
