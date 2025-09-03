//
//  PasteboardService.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 9/3/25.
//
import SwiftUI

struct CopyToPasteboardAction {
    func callAsFunction(text: String) {
#if canImport(UIKit)
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
#else
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
#endif
    }
}

extension EnvironmentValues {
    @Entry var copyToPasteBoard: CopyToPasteboardAction = CopyToPasteboardAction()
}
