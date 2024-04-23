//
//  Repository.swift
//  Record Player
//
//  Created by Евгений K on 23.04.2024.
//

import Foundation

public class MainRepository: ObservableObject {
    private static let baseUrl = "https://www.radiorecord.ru/api/"
    private let stationsUrl = "\(baseUrl)stations/"
    private let currentUrl = "\(baseUrl)stations/now/"

    @Published var data: [StationModel] = []
    
    func fetchStations() {
        guard let url = URL(string: stationsUrl) else { return }
        var stations: [StationModel] = []
        
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
    
    func fetchCurrent() -> [TrackWrapperModel] {
        guard let url = URL(string: currentUrl) else { return [] }
        var stations: [TrackWrapperModel] = []
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let posts = try JSONDecoder().decode(NowModel.self, from: data)
                DispatchQueue.main.async {
                    stations = posts.result
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
        
        return stations
    }
}
