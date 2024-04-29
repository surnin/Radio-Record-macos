//
//  Record_PlayerApp.swift
//  Record Player
//
//  Created by Евгений K on 21.04.2024.
//

import SwiftUI

@main
struct Record_PlayerApp: App {
    @State private var shortcutState: Shortcuts = .none
    
    var body: some Scene {
        WindowGroup {
            ContentView(shortcutState: shortcutState)
        }.commands {
            CommandGroup(replacing: .help) {
                /*Button(action: {}) {
                    Text("MyApp Help")
                }*/
            }
            CommandMenu("Commands") {
                Button(action: { shortcutState = .play }) {
                    Text("Play")
                }.keyboardShortcut(KeyEquivalent.home, modifiers: [.command, .control])
                Button(action: { shortcutState = .stop }) {
                    Text("Stop")
                }.keyboardShortcut(KeyEquivalent.end, modifiers: [.command, .control])
                Button(action: { shortcutState = .next }) {
                    Text("Next")
                }.keyboardShortcut(KeyEquivalent.pageDown, modifiers: [.command, .control])
                Button(action: { shortcutState = .previous }) {
                    Text("Previous")
                }.keyboardShortcut(KeyEquivalent.pageUp, modifiers: [.command, .control])
                Button(action: { shortcutState = .up }) {
                    Text("Volume Up")
                }.keyboardShortcut(KeyEquivalent.upArrow, modifiers: [.command, .control])
                Button(action: { shortcutState = .down }) {
                    Text("Volume Down")
                }.keyboardShortcut(KeyEquivalent.downArrow, modifiers: [.command, .control])
            }
        }
    }
}
