//
//  NSItemProvider+LoadFiles.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/30/25.
//
import Foundation
import UniformTypeIdentifiers

extension NSItemProvider {
    func tryLoadingInPlaceFileRepresentation(possibleTypes: [UTType], onCompleted: @escaping (URL?) -> Void) {
        guard let firstPossibleType = (possibleTypes.first { type in
            self.hasRepresentationConforming(toTypeIdentifier: type.identifier)
        }) else {
            onCompleted(nil)
            return
        }
        
        self.loadInPlaceFileRepresentation(forTypeIdentifier: firstPossibleType.identifier) { url, success, error in
            onCompleted(url)
        }
    }
    
    func tryLoadingInPlaceFileRepresentation(possibleTypes: [UTType]) async -> URL? {
        return await withCheckedContinuation { continuation in
            tryLoadingInPlaceFileRepresentation(possibleTypes: possibleTypes) { url in
                continuation.resume(returning: url)
            }
        }
    }
}
