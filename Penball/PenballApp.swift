//
//  PenballApp.swift
//  Penball
//
//  Created by Anthony Li on 4/15/21.
//

import SwiftUI
import PenballLib

let levels = [
    Level(name: "A Level", scene: PenballScene(fileNamed: "MyScene")!, allowsDrawing: true),
    Level(name: "A Level", scene: PenballScene(fileNamed: "MyScene")!, allowsDrawing: true)
]

@main
struct PenballApp: App {
    var body: some Scene {
        WindowGroup {
            PenballView(levels: levels)
        }
    }
}
