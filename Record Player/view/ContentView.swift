//
//  ContentView.swift
//  Record Player
//
//  Created by Евгений K on 21.04.2024.
//

import SwiftUI
import AVKit


struct ContentView: View {
    
    @StateObject private var presenter = MainPresenter()
    
    @State var shortcutState: Shortcuts = .none
    @State private var windowTitleState: String = "Record"
    @State private var isPlaying: Bool = false
    @State private var selection = "All"
    
    @AppStorage("volume") private var volumeState = 0.5
    
    private let categories = ["All", "Favourites"]
    private let player: AVPlayer
    
    init(shortcutState: Shortcuts) {
        player = AVPlayer(playerItem: nil)
        player.volume = Float(volumeState)
        self.shortcutState = shortcutState
    }
    
    var body: some View {
        List(presenter.filteredStations, id: \.id) { station in
            StationItem(
                id: station.id,
                title: station.title,
                artist: station.artist,
                song: station.song,
                svg: station.svg,
                isFav: false,
                onFav: presenter.onSetFav
            ).contentShape(Rectangle())
                .onTapGesture {
                    isPlaying = true
                    windowTitleState = "Record - \(station.title)"
                    playerPlay(station: presenter.onStationClick(station: station))
                }
        }
        .onAppear { presenter.onAppear() }
        .onChange(of: volumeState, perform: setPlayerVolume)
        .onChange(of: shortcutState) { newValue in
            print(newValue)
            if (newValue == Shortcuts.up) {
                setPlayerVolume(to: volumeState + 0.1)
            }
            if (newValue == Shortcuts.up) {
                setPlayerVolume(to: volumeState - 0.1)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(keys: [.space]) { press in
            isPlaying ? player.pause() : player.play()
            isPlaying = !isPlaying
            return .handled
        }
        .navigationTitle(windowTitleState)
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("Select categorie", selection: $selection) {
                    ForEach(categories, id: \.self) {
                        Text($0)
                    }
                }
                .disabled(true)
                .pickerStyle(.menu)
                TextField("Filter", text: $presenter.searchText)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: { 
                    player.pause()
                    isPlaying = !isPlaying}) {
                        Label("Stop", systemImage: "stop.fill")
                    }
                Button(action: { 
                    player.play()
                    isPlaying = !isPlaying}) {
                        Label("Play", systemImage: "play.fill")
                    }
                Slider(value: $volumeState, in: 0...1)
                    .frame(width: 100)
            }
        }
    }
    
    private func setPlayerVolume(to newValue: Double) {
        volumeState = newValue
        player.volume = Float(newValue)
    }
    
    private func playerPlay(station: String) {
        let url = URL(string: station)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}

#Preview {
    ContentView(shortcutState: Shortcuts.none)
}
