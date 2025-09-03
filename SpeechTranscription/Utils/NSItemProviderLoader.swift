//
//  NSItemProviderLoader.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 9/2/25.
//
import UniformTypeIdentifiers
import Foundation

class NSItemProviderLoader {
    let onCompleted: ([URL]) -> Void
    
    private var resultFiles = [URL?]()
    private var expectedCount: Int = 0
    private var queue: DispatchQueue
    
    init(queue: DispatchQueue, onCompleted: @escaping ([URL]) -> Void) {
        self.queue = queue
        self.onCompleted = onCompleted
    }
    
    /// This method should be called on the action block in ``onDrop(of:isTargeted:perform:)``.
    /// Don't post this method to other actors.
    ///
    /// You can get the result files in the ``onCompleted`` closure provided in the initializer.
    ///
    /// > Warning: According to ``onDrop(of:isTargeted:perform:)``,
    /// make sure to start loading the contents of NSItemProvider instances within the scope of the action closure.
    /// Do not perform loading asynchronously on a different actor. Loading the contents may finish later,
    /// but it must start here. For security reasons, the drop receiver can access the dropped payload only before this closure returns.
    func loadItems(providers: [NSItemProvider]) {
        expectedCount = providers.count
        
        for provider in providers {
            provider.tryLoadingInPlaceFileRepresentation(possibleTypes: [.audio, .folder]) { [weak self] url in
                guard let self else { return }
                resultFiles.append(url)
                checkCompletion()
            }
        }
    }
    
    private func checkCompletion() {
        if resultFiles.count == expectedCount {
            let files = resultFiles.compactMap { $0 }
            queue.async {
                self.onCompleted(files)
            }
        }
    }
}
