//
//  ContentView.swift
//  Record Player
//
//  Created by Евгений K on 21.04.2024.
//

import SwiftUI
import AVKit


struct ContentView: View {
    
    @ObservedObject var presenter: MainPresenter
    
    @State private var windowTitleState: String = "Record"
    @State private var isPlaying: Bool = false
    @State private var selection = "All"
    @State private var imageUrlState: String = ""
    @AppStorage("volume") var volumeState = 0.5
    
    private let categories = ["All", "Favourites"]
    private let player: AVPlayer
    
    init(presenter: MainPresenter) {
        self.presenter = presenter
        player = AVPlayer(playerItem: nil)
    }
    
    var body: some View {
        NavigationSplitView {
            VStack() {
                AsyncImage(url: URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music49/v4/f1/9b/9c/f19b9c18-d009-9b01-5446-9ea7598f6251/source/200x200bb.jpg"))
                    .frame(width: 200, height: 200, alignment: .top)
                Text("CRYSTAL LAKE/HEADHUNTERZ")
                Text("Say Goodbye")
                HStack{
                    Image(systemName: "square.and.arrow.up").help("Share track").onTapGesture {
                        
                    }
                    Image(systemName: "list.bullet.clipboard").help("Copy trackname to clipboard").onTapGesture {
                        
                    }
                }
            }
            .navigationSplitViewColumnWidth(250)
            .frame(alignment: .top)
        } detail: {
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
                        //                        presenter.onUpdateTracks()
                        imageUrlState = station.image
                        windowTitleState = "Record - \(station.title)"
                        stop()
                        playerPlay(station: presenter.onStationClick(station: station))
                    }
            }
            .onAppear {
                presenter.onAppear()
            }
            .focusable()
            .focusEffectDisabled()
            .onKeyPress(keys: [.space]) { press in
                isPlaying ? stop() : play(station: presenter.stationState)
                return .handled
            }
            .navigationTitle(windowTitleState)
            .onChange(of: presenter.shortcutState, perform: onHotkeyPressed)
            .onChange(of: volumeState, perform: setPlayerVolume)
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
                        stop()
                    }) {
                        Label("Stop", systemImage: "stop.fill")
                    }
                    Button(action: {
                        play(station: presenter.stationState)
                    }) {
                        Label("Play", systemImage: "play.fill")
                    }
                    Slider(value: $volumeState, in: 0...1)
                        .frame(width: 100)
                }
            }
        }
    }
    
    private func onHotkeyPressed(to shortcutState: Shortcuts) {
        print(shortcutState)
        switch(shortcutState) {
        case .play:
            play(station: presenter.stationState)
            break
        case .stop:
            stop()
            break
        case .next:
            print()
            break
        case .previous:
            print()
            break
        case .up:
            setPlayerVolume(to: volumeState + 0.1)
            break
        case .down:
            setPlayerVolume(to: volumeState - 0.1)
            break
        case .none:
            print()
            break
        }
    }
    
    private func play(station: StationData?) {
        isPlaying = true
        if let station = station {
            playerPlay(station: presenter.onStationClick(station: station))
        }
    }
    
    private func stop() {
        isPlaying = false
        player.pause()
    }
    
    private func setPlayerVolume(to newValue: Double) {
        print(newValue)
        volumeState = newValue
        player.volume = Float(newValue)
    }
    
    private func playerPlay(station: String) {
        print(station)
        let url = URL(string: station)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        player.volume = Float(volumeState)
    }
}

#Preview {
    ContentView(presenter: MainPresenter())
}
