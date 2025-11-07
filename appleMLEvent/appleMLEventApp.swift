//
//  appleMLEventApp.swift
//  appleMLEvent
//
//  Created by Ayaan Jain on 2/11/25.
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

@main
struct appleMLEventApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
