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
    @Published var info = ""
    @Published var error = ""
    @Published var isRecognizing = false

    func startRecognition() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }
            if authStatus == .authorized {
                self.startRecording()
            } else {
                DispatchQueue.main.async {
                    self.error = "音声認識の認証が許可されませんでした。"
                }
            }
        }
    }

    private func startRecording() {
        DispatchQueue.main.async {
            self.recognizedText = ""
            self.error = ""
            self.info = ""
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        if recordingFormat.sampleRate == 0.0 {
            DispatchQueue.main.async {
                self.error = "サンプルレートがゼロです"
            }
            return
        }
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        DispatchQueue.main.async {
            self.isRecognizing = true
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
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
        self.recognizedText = ""
        self.isRecognizing = false
    }
}
