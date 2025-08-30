//
//  FileDroppingHintView.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/30/25.
//
import SwiftUI

struct FilesDroppingHintView: View {
    var body: some View {
        VStack {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(.bottom)
            Text("Release to drop the files").font(.title2.bold())
        }.foregroundStyle(
            LinearGradient(
                colors: [.accent, .primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ).frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Rectangle().fill(.regularMaterial).ignoresSafeArea()
            }
    }
}

#Preview {
    FilesDroppingHintView()
}
