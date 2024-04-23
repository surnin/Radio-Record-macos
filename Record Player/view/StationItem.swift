//
//  StationItem.swift
//  Record Player
//
//  Created by Евгений K on 22.04.2024.
//

import SwiftUI

struct StationItem: View {
    var title: String
    var artist: String
    var song: String
    
    var body: some View {
        HStack {
            Text(title)
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: stationItemHeight,
            maxHeight: .infinity,
            alignment: .leading)
    }
}
