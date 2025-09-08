//
//  TranscriptionServiceWhisperImpl.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 9/9/25.
//
import Foundation
import Subprocess
import OSLog

/// This is an implementation for experiment.
/// The implementation here is to invoke the command line tool and then get the result from whisper.
///
/// More info: https://github.com/openai/whisper
///
/// ```bash
/// whisper fo.mp3 --model base --language ja
/// ```
///
/// Also, sandboxing should also be disabled, which may have a way to avoid disabling sandboxing:
///
/// https://developer.apple.com/documentation/xcode/embedding-a-helper-tool-in-a-sandboxed-app
class TranscriptionServiceByWhisper: TranscriptionService {
    nonisolated class TextFormatter {
        private let regex: Regex<Substring>
        
        init() throws {
            regex = try Regex<Substring>(#"\[.*?\]\s*"#)
        }

        func format(_ string: String) -> String {
            return string.replacing(regex, with: "")
        }
    }
    
    static var isAvailable: Bool {
        get async {
            do {
                let (exe, env) = try await getWhisperExecutable()
                let output = try await run(
                    exe,
                    arguments: .init(["--help"]),
                    environment: env,
                    output: .string(limit: Int.max, encoding: UTF8.self)
                )
                
                let isSuccess = output.terminationStatus.isSuccess == true
                let outputString = output.standardOutput
                AppLogger.defaultLogger.info("Whisper availability check, isSuccess: \(isSuccess), output: \(outputString ?? "nil")")
                
                return isSuccess == true
            } catch {
                AppLogger.defaultLogger.warning("Error checking whisper availability: \(error)")
                return false
            }
        }
    }
    
    static var shouldCheckAvailibilityAsync: Bool { true }
    static var supportsParallelTasks: Bool { false }
    
    @concurrent
    nonisolated func transcribeStream(
        source: TranscriptionTaskSource,
        locale: AppLocale,
        options: [String: Any]
    ) async throws -> some AsyncSequence<String, any Error> {
        return try await source.accessing { url in
            guard let dir = FileManager.default.urls(for: .cachesDirectory, in: .localDomainMask).first else {
                throw TranscriptionError(message: "Failed to get the cache dir")
            }
            
            // TODO: We may allow users to choose the model.
            let arguments = [
                url.path(),
                "--model",
                "turbo",
                "--language", locale.shortIdentifier,
                "--output_format", "txt",
                "--output_dir", dir.path()
            ]
            
            let stream = AsyncThrowingStream<String, any Error> { continuation in
                let task = Task.detached {
                    do {
                        let (exe, env) = try await getWhisperExecutable()
                        let result = try await run(
                            exe,
                            arguments: .init(arguments),
                            environment: env,
                            output: .string(limit: Int.max, encoding: UTF8.self)
                        )
                        
                        let formatter = try TextFormatter()
                        
                        /// For Whisper, it doesn't support streaming the result.
                        /// Specifically, if output the verbose result using ``print()`` in python,
                        /// which won't be flush to the standard output unless we modify the source code to do so.
                        /// Therefore, we just wait for the result here and yield the result.
                        if let output = result.standardOutput {
                            let formattedOutput = formatter.format(output)
                            continuation.yield(formattedOutput)
                            continuation.finish()
                        } else {
                            throw TranscriptionError(message: "Failed to get the standard output")
                        }
                    } catch {
                        AppLogger.defaultLogger.info("failed to run Whisper: \(error)")
                        continuation.finish(throwing: error)
                    }
                }
                
                continuation.onTermination = { _ in
                    AppLogger.defaultLogger.warning("onTermination")
                    task.cancel()
                }
            }
            
            return stream
        }
    }
}

private actor ExecutableEnvironment {
    private(set) var resultEnv = [String: String]()
    
    init() {
        resultEnv = ProcessInfo.processInfo.environment
    }
    
    func appendByAppendingCommonShells() -> [String: String] {
        appendByReading(path: "~/.zshrc")
        appendByReading(path: "~/.bashrc")
        
        let ffmpegDirCandidates = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
        ]
        let existingPATH = resultEnv["PATH"] ?? ""
        let additional = ffmpegDirCandidates
            .filter { !existingPATH.split(separator: ":").contains(Substring($0)) }
            .joined(separator: ":")
        resultEnv["PATH"] = additional.isEmpty ? existingPATH : existingPATH.isEmpty ? additional : "\(existingPATH):\(additional)"
        
        return resultEnv
    }
    
    private func appendByReading(path: String) {
        let zshrcFile = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: zshrcFile.path) else {
            return
        }
        guard let lines = try? String(contentsOf: zshrcFile, encoding: .utf8).split(separator: "\n") else {
            return
        }
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("export PATH=") {
                let pathValue = trimmed.replacingOccurrences(of: "export PATH=", with: "")
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                let paths = pathValue.split(separator: ":").map { String($0) }
                let existingPATH = resultEnv["PATH"] ?? ""
                let existingPaths = existingPATH.split(separator: ":").map { String($0) }
                let newPaths = paths.filter { !existingPaths.contains($0) }
                if !newPaths.isEmpty {
                    let updatedPATH = (existingPaths + newPaths).joined(separator: ":")
                    resultEnv["PATH"] = updatedPATH
                }
            }
        }
    }
}

private nonisolated func getWhisperExecutable() async throws -> (Executable, Environment) {
    let env = await ExecutableEnvironment().appendByAppendingCommonShells()
    var updatedEnv = [Environment.Key: String]()
    for (k, v) in env {
        updatedEnv[Environment.Key(rawValue: k)!] = v
    }
    let updatingEnv = Environment.inherit.updating(updatedEnv)
    let exeFilePath = try Executable.name("whisper")
        .resolveExecutablePath(in: updatingEnv)
    return (Executable.path(exeFilePath), updatingEnv)
}
