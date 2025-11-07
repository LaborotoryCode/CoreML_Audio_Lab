//
//  ContentView.swift
//  appleMLEvent
//
//  Created by Ayaan Jain on 2/11/25.
//

import SwiftUI
import AVFoundation
import Speech

struct TextToSpeechView: View {
    let synthesizer = AVSpeechSynthesizer()
    var body: some View {
        Button("Speak") {
            let utterance = AVSpeechUtterance(string: "Hello, World!")
            
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        }
    }
}

struct SpeechToTextView: View {
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: .current)
    
    @State var transcription = ""
    
    var body: some View {
        Button("Recognise") {
            SFSpeechRecognizer.requestAuthorization {
                status in guard status == .authorized else { return }
            }
            Task {
                let micGranted = await AVAudioApplication.requestRecordPermission()
                guard micGranted else { return }
                guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }
                
                let audioSession = AVCaptureSession()
                audioSession.beginConfiguration()
                audioSession.sessionPreset = .high
                
                let request = SFSpeechAudioBufferRecognitionRequest()
                request.shouldReportPartialResults = true
                
                let inputNode = audioEngine.inputNode
                let format = inputNode.outputFormat(forBus: 0)
                
                inputNode.removeTap(onBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) {
                    buffer, _ in request.append(buffer)
                }
                audioEngine.prepare()
                try? audioEngine.start()
                
                recognizer.recognitionTask(with: request) { result, _ in
                    if let result {
                        transcription = result.bestTranscription.formattedString
                    }
                }
            }
        }
        Text(transcription)
                .padding()
                .frame(maxWidth: 750, alignment: .leading)
                .border(Color.gray)
    }
}

final class AudioDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // Handle audio samples if needed
        print("Received audio buffer")
    }
}

#Preview {
    VStack(spacing: 20) {
            Button("Synthesise") {}
            Button("Recognise") {}
        }
}
