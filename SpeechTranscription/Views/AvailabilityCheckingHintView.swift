//
//  AvailibilityCheckingHintVivew.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 9/9/25.
//
import SwiftUI

struct AvailabilityCheckingHintView: View {
    var body: some View {
        VStack {
            ProgressView().controlSize(.large)
            Text("Checking availability...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Material.regular)
    }
}
