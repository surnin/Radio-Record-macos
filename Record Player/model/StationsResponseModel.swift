//
//  StationsResponseModel.swift
//  Record Player
//
//  Created by Евгений K on 22.04.2024.
//

struct StationModel: Codable {
    let id: Int
    let title: String
    let prefix: String
    let svg_outline: String
}

struct StationTagsModel: Codable {
    let stations: [StationModel]
}

struct StationResultModel: Codable {
    let result: StationTagsModel
}

extension StationModel {
    func map() -> StationData {
        return StationData(id: id,
                           title: self.title,
                           prefix: self.prefix,
                           svg: self.svg_outline,
                           artist: String(),
                           song: String(),
                           isFav: false,
                           image: String(),
                           shareUrl: String()
        )
    }
}
