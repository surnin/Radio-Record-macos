//
//  MainPresenter.swift
//  Record Player
//
//  Created by Евгений K on 23.04.2024.
//

import Foundation

public class MainPresenter: ObservableObject {
    private let favouritesKey = "favourites"
    private static let baseUrl = "https://www.radiorecord.ru/api/"
    private let stationsUrl = "\(baseUrl)stations/"
    private let currentUrl = "\(baseUrl)stations/now/"
    
    @Published var data: [StationData] = []
    @Published var searchText: String = ""
    
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
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func onStationClick(station: StationData) -> String {
        let prefix = if (station.prefix == "record") {
            "record"
        } else {
            "record-\(station.prefix)"
        }
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
                        let newItem = now.first(where: { $0.id == item.id})
                        
                        return StationData(
                            id: item.id,
                            title: item.title,
                            prefix: item.prefix,
                            tooltip: item.tooltip,
                            svg: item.svg,
                            artist: newItem?.track.artist ?? String(),
                            song: newItem?.track.song ?? String(),
                            isFav: false
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
