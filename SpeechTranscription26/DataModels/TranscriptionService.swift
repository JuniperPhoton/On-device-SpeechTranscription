//
//  TranscriptionService.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/28/25.
//
import Foundation
import OSLog
import Speech

protocol TranscriptionService {
    associatedtype AsyncSequenceType: AsyncSequence<String, any Error>
    static var isAvailable: Bool { get }
    nonisolated func transcribe(source: TranscriptionTaskSource, locale: AppLocale) async throws -> String?
    nonisolated func transcribeStream(source: TranscriptionTaskSource, locale: AppLocale) async throws -> AsyncSequenceType
}

class TranscriptionServiceStub: TranscriptionService {
    static var isAvailable: Bool {
        false
    }
    
    nonisolated func transcribe(
        source: TranscriptionTaskSource,
        locale: AppLocale
    ) async throws -> String? {
        throw NSError(
            domain: "TranscriptionServiceStub",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Transcription service is not available."]
        )
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
    
    nonisolated func transcribe(
        source: TranscriptionTaskSource,
        locale: AppLocale
    ) async throws -> String? {
        try await source.accessing { url in
            let transcriber = SpeechTranscriber(
                locale: Locale(identifier: locale.identifier),
                preset: .transcription
            )
            
            let analyzer = SpeechAnalyzer(modules: [transcriber])
            try await analyzer.start(inputAudioFile: .init(forReading: url), finishAfterFile: true)
            
            var resultString: AttributedString = ""
            
            do {
                for try await transcription in transcriber.results.filter({ $0.isFinal }) {
                    resultString = resultString + transcription.text + "\n"
                }
            } catch {
                AppLogger.defaultLogger.log("Transcription error: \(error)")
            }
            
            return resultString.characters.flatMap { String($0.utf8) }.reduce("") { partialResult, c in
                partialResult + String(c)
            }.trimmingCharacters(in: .newlines)
        }
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
