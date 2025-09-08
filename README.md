# On-device Speech Transcription for macOS 26

This app leverages the new `SpeechAnalyzer` API from the [Speech framework](https://developer.apple.com/documentation/speech/bringing-advanced-speech-to-text-capabilities-to-your-app?changes=_1) introduced since macOS 26 this year.

Some key features:

- It uses an on-device model to do the transcription, which is provided by the macOS system. It should respect your privacy and won't upload any text to any servers.
- You can transcribe multiple files all at once.
- It supports Japanese, English, Simplified Chinese, Traditional Chinese, and Cantonese out of the box. You can also modify the code to support more locales. Note that your Mac may not have downloaded some of the models, and you can manage the downloads via the SpeechTranscription26 -> Settings page.
- It's built with SwiftUI using Liquid Glass design. Dropping operation is also supported.
- For text rendering, it uses a bridged version of `NSTextView` to achieve better performance for long text. Of course, text is selectable and copiable.
- Font size and line spacing are adjustable via the Transcription menu.

![Snipaste_2025-09-03_22-19-29](https://github.com/user-attachments/assets/e4a53466-be3c-45a8-b4fc-7c96c7a2be37)

# Install & Build

Whether you choose to build it yourself or install the pre-built package, you have to make sure that you are running macOS 26 Beta 8 or later.

## Install

Navigate to the [Release](https://github.com/JuniperPhoton/SpeechTranscription/releases) section to view the latest releases.

## Build the project yourself

Open the project with Xcode 26 Beta, and build it as usual.

# Notes

I built this mainly for my own purpose, and I have tested this on my MacBook Pro with M1 Pro on macOS 26 Beta 8. Some unknown cases:

- I am not quite sure whether this on-device model requires Apple Intelligence or not. If you have tested this on a MacBook that doesn't support Apple Intelligence, please leave your feedback in the issues section.
- You should test the accuracy on your own. In my experience, transcribing the textbook-level speech has higher accuracy, while transcribing animes may not be as good, sicne the on-device model is not trained for those materials.

# MIT License

Copyright (c) 2025 Weichao Deng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
