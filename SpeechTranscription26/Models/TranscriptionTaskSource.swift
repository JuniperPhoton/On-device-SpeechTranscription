//
//  TranscriptionTaskSource.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 9/2/25.
//
import Foundation

struct TranscriptionTaskSource: Identifiable, Equatable {
    /// The original picked file, may be a folder.
    /// By referencing this URL, we can get the permission to access the actual ``fileURL`` file.
    ///
    /// If users picked a file, then ``referencingSourceURL`` and ``fileURL`` are the same.
    ///
    /// Note: currently, I opt out of sandbox to avoid the issue where dropped folder can't be accessed.
    /// To opt in sandbox, we need to handle security-scoped access properly.
    let referencingSourceURL: URL
    
    let fileURL: URL
    
    var id: String {
        fileURL.absoluteString
    }
    
    @inlinable
    nonisolated func accessing<T>(action: @escaping (URL) async throws -> T) async throws -> T {
        _ = referencingSourceURL.startAccessingSecurityScopedResource()
        defer {
            referencingSourceURL.stopAccessingSecurityScopedResource()
        }
        return try await action(fileURL)
    }
}
