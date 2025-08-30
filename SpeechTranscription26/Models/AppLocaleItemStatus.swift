//
//  AppLocaleItemStatus.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/30/25.
//
import Foundation

enum AppLocaleItemStatus: Hashable {
    case pending
    case installed
    case downloading(progress: CGFloat)
}
