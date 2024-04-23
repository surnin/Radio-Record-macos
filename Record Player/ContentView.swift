//
//  ContentView.swift
//  Record Player
//
//  Created by Евгений K on 21.04.2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var presenter = MainPresenter()
    
    @State private var volumeState: Float = 0.5
    @State private var windowTitleState: String = "Record"
    @State private var selection = "All"
    let categories = ["All", "Favourites"]
    
    let player = AVPlayer(playerItem: nil)
    
    var body: some View {
        List(presenter.filteredStations, id: \.id) { station in
            StationItem(
                title: station.title,
                artist: station.artist ?? "",
                song: station.song ?? ""
            ).contentShape(Rectangle())
                .onTapGesture {
                    windowTitleState = "Record - \(station.title)"
                    playerPlay(station: presenter.onStationClick(station: station))
                }
        }
        .onAppear { presenter.onAppear() }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(keys: [.space]) { press in
            player.pause()
            
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
                Button(action: { player.pause() }) {
                    Label("Stop", systemImage: "stop.fill")
                }
                Button(action: { player.play() }) {
                    Label("Play", systemImage: "play.fill")
                }
                Slider(value: $volumeState, in: 0...1)
                    .onChange(of: volumeState, perform: setPlayerVolume)
                    .frame(width: 100)
            }
        }
    }
    
    func setPlayerVolume(to newValue: Float) {
        player.volume = newValue
    }
    
    func playerPlay(station: String) {
        let url = URL(string: station)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}

#Preview {
    ContentView()
}
