//
//  ContentView.swift
//  SpeechToTextOverlay
//
//  Created by Ayaan Jain on 6/11/25.
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
                .padding()
                .frame(maxWidth: geometry.size.width * 0.6, maxHeight: 50)
                .background()
                .truncationMode(.head)
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
                        DispatchQueue.main.async {
                                transcript = result.bestTranscription.formattedString
                                withAnimation {
                                    print(result.bestTranscription.formattedString)
                                }
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
