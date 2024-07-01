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
        VStack {
            Text(speechRecognizer.recognizedText)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()

            Button(action: {
                speechRecognizer.startRecognition()
            }) {
                Text("Start Recognition")
            }

            Button(action: {
                speechRecognizer.stopRecognition()
            }) {
                Text("Stop Recognition")
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
