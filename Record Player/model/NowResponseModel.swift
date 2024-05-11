//
//  NowResponseModel.swift
//  Record Player
//
//  Created by Евгений K on 22.04.2024.
//

struct NowModel: Codable {
    let result: [TrackWrapperModel]
}

struct TrackWrapperModel: Codable {
    let id: Int
    let track: TrackModel
}

struct TrackModel: Codable {
    let id: Int
    let artist: String
    let song: String
    let image200: String
    let shareUrl: String
}
