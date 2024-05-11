//
//  MainPresenter.swift
//  Record Player
//
//  Created by Евгений K on 23.04.2024.
//

import Foundation
import SwiftUI
import MediaPlayer

public class MainPresenter: ObservableObject {
    private let favouritesKey = "favourites"
    private static let baseUrl = "https://www.radiorecord.ru/api/"
    private let stationsUrl = "\(baseUrl)stations/"
    private let currentUrl = "\(baseUrl)stations/now/"
    
    private let player: AVPlayer
    private var isPlaying: Bool = false
    
    @Published var data: [StationData] = []
    @Published var searchText: String = ""
    @Published var stationState: StationData? = nil
    @Published var windowTitleState: String = "Record"
    @Published var songPanelIsShowing = NavigationSplitViewVisibility.detailOnly
    @AppStorage("volume") var volumeState = 0.5
    
    init() {
        player = AVPlayer(playerItem: nil)
    }
    
    var favouritesSet: Set<Int> {
        get {
            return UserDefaults.standard.object(forKey: favouritesKey) as? Set<Int> ?? Set<Int>()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: favouritesKey)
        }
    }
    
    var filteredStations: [StationData] {
        guard !searchText.isEmpty else { return data }
        return data.filter { station in
            station.title.lowercased().contains(searchText.lowercased())
        }
    }
    
    func onAppear() {
        guard let url = URL(string: stationsUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let posts = try JSONDecoder().decode(StationResultModel.self, from: data)
                DispatchQueue.main.async {
                    self.data = posts.result.stations.map { $0.map() }
                    self.updateTracks()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    private func updateTracks() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { timer in self.onUpdateTracks() })
    }
    
    private func updateCurrentTrack() {
        data.forEach { item in
            if item.id == stationState?.id {
                stationState = item
            }
        }
    }
    
    private func getStationUrl(station: StationData) -> String {
        let prefix = if (station.prefix == "record") {
            "record"
        } else {
            "record-\(station.prefix.replacingOccurrences(of: "-", with: ""))"
        }
        return "https://hls-01-radiorecord.hostingradio.ru/\(prefix)/playlist.m3u8"
    }
    
    func onStationClick(station: StationData) {
        stationState = station
        windowTitleState = "Record - \(station.title)"
        setNowPlayingMetadata(metadata: station)
        play(station: station)
        onUpdateTracks()
        songPanelIsShowing = .automatic
    }
    
    private func onUpdateTracks() {
        guard let url = URL(string: currentUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let posts = try JSONDecoder().decode(NowModel.self, from: data)
                DispatchQueue.main.async {
                    let now = posts.result
                    
                    self.data = self.data.map { item in
                        let newItem = now.first(where: { $0.id == item.id})?.track
                        
                        return StationData(
                            id: item.id,
                            title: item.title,
                            prefix: item.prefix,
                            svg: item.svg,
                            artist: newItem?.artist ?? String(),
                            song: newItem?.song ?? String(),
                            isFav: false,
                            image: newItem?.image200 ?? String(),
                            shareUrl: newItem?.shareUrl ?? String()
                        )
                    }
                    
                    self.updateCurrentTrack()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func onSetFav(to id: Int) {
        print(id)
    }
    
    private func setNowPlayingMetadata(metadata: StationData) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        //        nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = URL(string: metadata.image)
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.artist
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.song
        //        nowPlayingInfo[MPMediaItemPropertyArtwork] = metadata.image
        
        print(nowPlayingInfo)
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func onVolumeChange(volume: Double) {
        player.volume = Float(volume)
    }
    
    func onStopClick() {
        stop()
    }
    
    func onPlayClick() {
        if isPlaying { return }
        guard let station = stationState else { return }
        play(station: station)
    }
    
    private func play(station: StationData?) {
        guard let station = station else { return }
        isPlaying = true
        playerPlay(station: getStationUrl(station: station))
    }
    
    private func stop() {
        isPlaying = false
        player.pause()
    }
    
    private func playerPlay(station: String) {
        let url = URL(string: station)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        player.volume = Float(volumeState)
    }
    
    func onHotkeyPressed(shortcutState: Shortcuts) {
        let shortcutState = shortcutState
        
        switch(shortcutState) {
            case .play:
                play(station: stationState)
                break
            case .stop:
                stop()
                break
            case .next:
                for (index, item) in data.enumerated() {
                    if (item.id == stationState?.id) {
                        let nextIndex = index == (data.count - 1) ? 0 : index + 1
                        let station = data[nextIndex]
                        onStationClick(station: station)
                        break
                    }
                }
                break
            case .previous:
                for (index, item) in data.enumerated() {
                    if (item.id == stationState?.id) {
                        let nextIndex = index == 0 ? (data.count - 1 ) : index - 1
                        let station = data[nextIndex]
                        onStationClick(station: station)
                        break
                    }
                }
                break
            case .up:
                if volumeState < 1 {
                    volumeState += 0.1
                }
                break
            case .down:
                if volumeState > 0 {
                    volumeState -= 0.1
                }
                break
            case .none:
                print()
                break
        }
    }
    
    func onShareClick() {
        guard let station = stationState else { return }
        copyToClipboard(string: "\(station.shareUrl)")
    }
    
    func onClipboardClick() {
        guard let station = stationState else { return }
        copyToClipboard(string: "\(station.artist) - \(station.song)")
    }
    
    private func copyToClipboard(string: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(string, forType: .string)
    }
    
    func onSpacePressed() {
        guard let station = stationState else { return }
        isPlaying ? stop() : onStationClick(station: station)
    }
}
