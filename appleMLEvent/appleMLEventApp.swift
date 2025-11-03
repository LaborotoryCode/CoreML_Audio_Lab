//
//  appleMLEventApp.swift
//  appleMLEvent
//
//  Created by Ayaan Jain on 2/11/25.
//

import SwiftUI
import SwiftData

@main
struct appleMLEventApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            VStack {
                        SpeechToTextView()
                        TextToSpeechView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
