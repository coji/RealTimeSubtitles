//
//  ContentView.swift
//  RealTimeSubtitles
//
//  Created by coji on 2024/07/01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        // 字幕表示エリア
        VStack {
            Spacer()
            Text("\(speechRecognizer.recognizedText)")
                .font(.extraLargeTitle)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 50) // 下部に固定

            Toggle(isOn: $speechRecognizer.isRecognizing) {
                Text("音声認識")
            }
        }
        .onAppear {
            speechRecognizer.startRecognition()
        }
        .onDisappear {
            speechRecognizer.stopRecognition()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
