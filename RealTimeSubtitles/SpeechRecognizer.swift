//
//  SpeechRecognizer.swift
//  RealTimeSubtitles
//
//  Created by coji on 2024/07/01.
//
import SwiftUI
import Speech

class SpeechRecognizer: ObservableObject {
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    @Published var recognizedText = ""

    func startRecognition() {
        self.recognizedText = "Start recognition"
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                self.startRecording()
            } else {
                // Handle the error
            }
        }
    }

    private func startRecording() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0) // 既存のタップを削除
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            } else if let error = error {
                // Handle the error
                print(error)
            }
        }
    }

    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        self.recognizedText = "Recognition stopped"
    }
}
