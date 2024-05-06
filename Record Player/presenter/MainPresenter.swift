//
//  MainPresenter.swift
//  Record Player
//
//  Created by Евгений K on 23.04.2024.
//

import Foundation
import SwiftUI

public class MainPresenter: ObservableObject {
    private let favouritesKey = "favourites"
    private static let baseUrl = "https://www.radiorecord.ru/api/"
    private let stationsUrl = "\(baseUrl)stations/"
    private let currentUrl = "\(baseUrl)stations/now/"
    
    @Published var data: [StationData] = []
    @Published var searchText: String = ""
    @Published var stationState: StationData? = nil
    @Published var shortcutState: Shortcuts = .none
    
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
                    print(posts.result.stations[0].svg_outline)
                    self.data = posts.result.stations.map { $0.map() }
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func onStationClick(station: StationData) -> String {
        stationState = station
        let prefix = if (station.prefix == "record") {
            "record"
        } else {
            "record-\(station.prefix.replacingOccurrences(of: "-", with: ""))"
        }
        print(prefix)
        return "https://hls-01-radiorecord.hostingradio.ru/\(prefix)/playlist.m3u8"
    }
    
    //MARK: Useless yet
    func onUpdateTracks() {
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
                            image: newItem?.image600 ?? String(),
                            shareUrl: newItem?.shareUrl ?? String()
                        )
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func onSetFav(to id: Int) {
        print(id)
    }
}
