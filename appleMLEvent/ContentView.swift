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
                
                guard let mic = AVCaptureDevice.default(for: .audio),
                      let micInput = try? AVCaptureDeviceInput(device: mic) else {
                    print("No audio input available")
                    return
                }
                if audioSession.canAddInput(micInput) {
                    audioSession.addInput(micInput)
                }
                let audioOutput = AVCaptureAudioDataOutput()   // correct class
                audioOutput.setSampleBufferDelegate(AudioDelegate(), queue: DispatchQueue(label: "AudioQueue"))
                if audioSession.canAddOutput(audioOutput) {
                    audioSession.addOutput(audioOutput)
                }
                let queue = DispatchQueue(label: "AudioQueue")
                audioOutput.setSampleBufferDelegate(AudioDelegate(), queue: queue)
                
                if audioSession.canAddOutput(audioOutput) {
                    audioSession.addOutput(audioOutput)
                }
                
                audioSession.commitConfiguration()
                audioSession.startRunning()
                
                print("Audio capture started (macOS equivalent of AVAudioSession.setActive(true))")
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
                        print(result.bestTranscription.formattedString)
                    }
                }
            }
        }
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
            Button("Recognise") {}
            Button("Synthesise") {}
        }
}
