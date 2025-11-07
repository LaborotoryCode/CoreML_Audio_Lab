//
//  AudioDelegate.swift
//  SpeechToTextOverlay
//
//  Created by Tristan Chay on 8/11/25.
//

import Foundation
import AVFoundation

final class AudioDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
    }
}
