//
//  StationItem.swift
//  Record Player
//
//  Created by Евгений K on 22.04.2024.
//

import SwiftUI

struct StationItem: View {
    @State private var starState = Favourite.star
    
    var id: Int
    var title: String
    var artist: String
    var song: String
    var svg: String
    @State var isFav: Bool
    var onFav: (Int) -> Void
    
    var body: some View {
        HStack {
            /*SVGWebView(svg: svg)
                .frame(width: 40, height: 40)*/
            Text(title)
            Image(systemName: starState.rawValue)
                .onTapGesture {
                    onFav(self.id)
                    
                    switch isFav {
                        case false:
                            starState = Favourite.fill
                        case true:
                            starState = Favourite.star
                    }
                    
                    isFav.toggle()
                }
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: stationItemHeight,
            maxHeight: .infinity,
            alignment: .leading)
    }
}

enum Favourite: String {
    case star = "star"
    case fill = "star.fill"
}
