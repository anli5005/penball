//
//  PenballApp.swift
//  Penball
//
//  Created by Anthony Li on 4/15/21.
//

import SwiftUI
import PenballLib

let levels = [
    Level(id: "Test1", scene: PenballScene(fileNamed: "MyScene")!),
    Level(id: "Test2", scene: PenballScene(fileNamed: "MyScene")!),
    Level(id: "Test3", scene: PenballScene(fileNamed: "MyScene")!, allowsDrawing: false)
]

@main
struct PenballApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State var bests = [String: Score]()
    
    var body: some View {
        PenballView(levels: levels, bests: $bests)
    }
}
