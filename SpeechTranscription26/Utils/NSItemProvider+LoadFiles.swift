//
//  NSItemProvider+LoadFiles.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/30/25.
//
import Foundation
import UniformTypeIdentifiers

extension NSItemProvider {
    func tryLoadAsAudioFileRepresentation() async -> URL? {
        return await withCheckedContinuation { continuation in
            _ = self.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.audio.identifier) { url, success, error in
                continuation.resume(returning: url)
            }
        }
    }
}
