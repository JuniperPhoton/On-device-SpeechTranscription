//
//  SpeechTranscriptionTests.swift
//  SpeechTranscriptionTests
//
//  Created by juniperphoton on 9/10/25.
//

import Testing
@testable import SpeechTranscription

struct StandardOutputTextFormatterTests {
    @Test func testStandardOutputTextFormatter() async throws {
        let formatter = try TranscriptionServiceByWhisper.TextFormatter()
        var output = formatter.format("Hello, world!")
        #expect(output == "Hello, world!")
        
        output = formatter.format("[01:19.000 --> 01:26.000] Hello, world!")
        #expect(output == "Hello, world!")
        
        output = formatter.format("[01:19.000,01:26.000] Hello, world!")
        #expect(output == "Hello, world!")
        
        output = formatter.format("[01:19.00001:26.000] Hello, world!")
        #expect(output == "Hello, world!")
    }
}
