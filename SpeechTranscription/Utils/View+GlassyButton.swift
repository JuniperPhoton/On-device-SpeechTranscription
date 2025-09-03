//
//  View+GlassyButton.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/30/25.
//
import SwiftUI

extension View {
    func glassyButtonLabel(tintColor: Color? = nil, shape: some Shape = Capsule()) -> some View {
        self.labelStyle(.titleAndIcon)
            .padding(12)
            .frame(maxWidth: .infinity)
            .contentShape(Capsule())
            .glassEffect(.regular.interactive().tint(tintColor), in: shape)
    }
}
