//
//  Record_PlayerApp.swift
//  Record Player
//
//  Created by Евгений K on 21.04.2024.
//

import SwiftUI
import HotKey

@main
struct Record_PlayerApp: App {
    @StateObject private var presenter = MainPresenter()
    
    let hotkeyPlay = HotKey(key: .home, modifiers: [.command, .control])
    let hotkeyStop = HotKey(key: .end, modifiers: [.command, .control])
    let hotkeyNext = HotKey(key: .pageDown, modifiers: [.command, .control])
    let hotkeyPrevious = HotKey(key: .pageUp, modifiers: [.command, .control])
    let hotkeyVolumeUp = HotKey(key: .upArrow, modifiers: [.command, .control])
    let hotkeyVolumeDown = HotKey(key: .downArrow, modifiers: [.command, .control])
    
    var body: some Scene {
        WindowGroup {
            ContentView(presenter: self.presenter)
                .onAppear() {
                    hotkeyPlay.keyDownHandler = onPlay
                    hotkeyStop.keyDownHandler = onPause
                    hotkeyNext.keyDownHandler = onNext
                    hotkeyPrevious.keyDownHandler = onPrevious
                    hotkeyVolumeUp.keyDownHandler = onVolumeUp
                    hotkeyVolumeDown.keyDownHandler = onVolumeDown
                }
        }.commands {
            CommandMenu("Commands") {
                Button(action: onPlay) {
                    Text("Play")
                }.keyboardShortcut(KeyEquivalent.home, modifiers: [.command, .control])
                Button(action: onPause) {
                    Text("Stop")
                }.keyboardShortcut(KeyEquivalent.end, modifiers: [.command, .control])
                Button(action: onNext) {
                    Text("Next")
                }.keyboardShortcut(KeyEquivalent.pageDown, modifiers: [.command, .control])
                Button(action: onPrevious) {
                    Text("Previous")
                }.keyboardShortcut(KeyEquivalent.pageUp, modifiers: [.command, .control])
                Button(action: onVolumeUp) {
                    Text("Volume Up")
                }.keyboardShortcut(KeyEquivalent.upArrow, modifiers: [.command, .control])
                Button(action: onVolumeDown) {
                    Text("Volume Down")
                }.keyboardShortcut(KeyEquivalent.downArrow, modifiers: [.command, .control])
            }
        }
    }
    
    private func onPlay() { presenter.shortcutState = .play }
    private func onPause() { presenter.shortcutState = .stop }
    private func onNext() { presenter.shortcutState = .next }
    private func onPrevious() { presenter.shortcutState = .previous }
    private func onVolumeUp() { presenter.shortcutState = .up }
    private func onVolumeDown() { presenter.shortcutState = .down }
}
