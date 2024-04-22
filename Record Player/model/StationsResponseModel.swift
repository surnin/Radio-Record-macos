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
}

struct StationTagsModel: Codable {
    let stations: [StationModel]
}

struct StationResultModel: Codable {
    let result: StationTagsModel
}
