//
//  ContentView.swift
//  Record Player
//
//  Created by Евгений K on 21.04.2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State private var data: [StationModel] = []
    @State private var volumeState: Float = 0.5
    @State private var windowTitleState: String = "Record"
    
    let player = AVPlayer(playerItem: nil)
    
    var body: some View {
        List(data, id: \.id) { station in
            StationItem(title: station.title)
                .contentShape(Rectangle())
                .onTapGesture {
                    playerPlay(station: station)
                }
        }
        .onAppear { fetchData() }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(keys: [.space]) { press in
            print(press)
            player.pause()
            
            return .handled
        }
        .navigationTitle(windowTitleState)
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { player.pause() }) {
                    Label("Record Progress",
                          systemImage: "stop.fill")
                }
                Button(action: { player.play() }) {
                    Label("Record Progress",
                          systemImage: "play.fill")
                }
                Slider(value: $volumeState, in: 0...1)
                    .onChange(of: volumeState, perform: setPlayerVolume)
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            }
        }
    }
    
    func setPlayerVolume(to newValue: Float) {
        player.volume = newValue
    }
    
    func playerPlay(station: StationModel) {
        windowTitleState = "Record - \(station.title)"
        let prefix = if (station.prefix == "record") {
            "record"
        } else {
            "record-\(station.prefix)"
        }
        let url = "https://hls-01-radiorecord.hostingradio.ru/\(prefix)/playlist.m3u8"
        
        player.replaceCurrentItem(
            with: AVPlayerItem(
                url: URL(
                    string: url
                )!
            )
        )
        player.play()
    }
    
    func fetchData() {
        guard let url = URL(string: "https://www.radiorecord.ru/api/stations") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let posts = try JSONDecoder().decode(StationResultModel.self, from: data)
                DispatchQueue.main.async {
                    self.data = posts.result.stations
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
