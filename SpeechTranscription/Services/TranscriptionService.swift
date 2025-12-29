//
//  TranscriptionService.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/28/25.
//
import Foundation
import OSLog

enum AvailibilityCheckingStatus {
    case checking
    case supported
    case notSupported
}

protocol TranscriptionService {
    /// The async sequence type that the service uses to stream the transcription result.
    associatedtype AsyncSequenceType: AsyncSequence<String, any Error>

    /// Check whether the transcription service is available on the current device.
    static var isAvailable: Bool { get async }
    
    /// Whether the service supports multiple parallel transcription tasks.
    /// For implementation that invokes external API, it is recommended to return `false`.
    static var supportsParallelTasks: Bool { get }
    
    /// Whether the availibility checking is an async operation.
    /// If it's true, the app will show a loading indicator while checking at launch.
    static var shouldCheckAvailibilityAsync: Bool { get }

    /// Transcribe the file to the text in a streaming manner.
    /// So text can be displayed while transcription is still in progress.
    nonisolated func transcribeStream(
        source: TranscriptionTaskSource,
        locale: AppLocale,
        options: [String: Any]
    ) async throws -> AsyncSequenceType
}

extension TranscriptionService {
    /// Transcribe the file to the text.
    /// This will collect all the values in ``transcribeStream(source:locale:)`` and return the final result.
    nonisolated func transcribe(
        source: TranscriptionTaskSource,
        locale: AppLocale,
        options: [String: Any]
    ) async throws -> String? {
        let stream = try await transcribeStream(source: source, locale: locale, options: options)
        return try await stream.reduce(into: "") { partialResult, c in
            partialResult = c + partialResult + "\n"
        }.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

class TranscriptionServiceStub: TranscriptionService {
    static var isAvailable: Bool { false }
    static var supportsParallelTasks: Bool { false }
    static var shouldCheckAvailibilityAsync: Bool { false }

    nonisolated func transcribeStream(
        source: TranscriptionTaskSource,
        locale: AppLocale,
        options: [String: Any]
    ) async throws -> AsyncThrowingStream<String, any Error> {
        AppLogger.defaultLogger.warning("You are using a stub for TranscriptionService. This will always fail.")
        throw TranscriptionError(message: "Transcription service is not available for TranscriptionServiceStub")
    }
}
