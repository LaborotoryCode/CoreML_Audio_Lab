//
//  ContentView.swift
//  SpeechToTextOverlay
//
//  Created by Tristan Chay on 8/11/25.
//

import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: .current)

    @State private var transcript = ""

    var body: some View {
        GeometryReader { geometry in
            Text(transcript)
                .contentTransition(.numericText())
                .font(.largeTitle)
                .foregroundStyle(.black)
                .padding()
                .frame(maxWidth: transcript.isEmpty ? 0 : geometry.size.width * 0.6)
                .glassEffect(.regular, in: RoundedRectangle(cornerSize: CGSize(width: 32, height: 32), style: .continuous))
                .shadow(radius: 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(60)
        }
        .background(WindowAccessor { window in
            window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()) + 1)
            window.styleMask.insert(.fullSizeContentView)
            window.styleMask.remove([.closable, .fullScreen, .miniaturizable, .resizable])
            window.hasShadow = false

            // Set borderless last because assigning a mask replaces flags
            window.styleMask = [.borderless]

            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
            window.backgroundColor = .clear
            window.titlebarAppearsTransparent = true
            window.title = ""
            window.toolbar = nil
            window.isMovableByWindowBackground = false

            if let rect = NSScreen.screens.first?.frame {
                window.setFrame(rect, display: true)
            }
            window.isMovable = false
            window.titleVisibility = .hidden
            window.makeKeyAndOrderFront(nil)
        })
        .ignoresSafeArea()
        .onAppear {
            SFSpeechRecognizer.requestAuthorization { status in
                guard status == .authorized else { return }
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
                let audioOutput = AVCaptureAudioDataOutput()
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
                        withAnimation {
                            transcript = result.bestTranscription.formattedString
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
