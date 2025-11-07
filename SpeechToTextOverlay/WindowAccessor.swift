//
//  WindowAccessor.swift
//  SpeechToTextOverlay
//
//  Created by Tristan Chay on 8/11/25.
//

import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    var onResolve: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            if let win = view?.window {
                onResolve(win)
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
