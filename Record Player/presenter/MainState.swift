//
//  MainState.swift
//  Record Player
//
//  Created by Евгений K on 11.05.2024.
//

import Foundation
import SwiftUI

struct MainState {
    var searchText: String
    var windowTitleState: String
    var stationState: StationData?
    var data: [StationData]
    var songPanelIsShowing: NavigationSplitViewVisibility
}
