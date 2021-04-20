//
//  PenballApp.swift
//  Penball
//
//  Created by Anthony Li on 4/15/21.
//

import SwiftUI
import PencilKit
import PenballLib
import PenballEditor

@main
struct PenballApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

let levelJSON = try! Data(contentsOf: Bundle.main.url(forResource: "Level", withExtension: "json")!)
let levels = [
    Level(id: "test", name: "Test", from: try! JSONDecoder().decode(LevelDefinition.self, from: levelJSON)),
    Level(id: "test2", name: "Test", from: try! JSONDecoder().decode(LevelDefinition.self, from: levelJSON))
]


struct ContentView: View {
    @State var bests = [String: Score]()
    
    @State var drawing = PKDrawing()
    @State var strokeTypes = [Double: PenballEditor.ObjectType]()
    @State var balls = [PenballEditor.Ball]()
    
    var body: some View {
        TabView {
            PenballView(levels: levels, bests: $bests).tabItem { Text("Levels") }
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    PenballEditor(drawing: $drawing, strokeTypes: $strokeTypes, balls: $balls)
                    Button("Copy JSON") {
                        let level = LevelDefinition(drawing: drawing, strokeTypes: strokeTypes, balls: balls, sceneHeight: geometry.size.height)
                        let encoder = JSONEncoder()
                        let json = try! String(data: encoder.encode(level), encoding: .utf8)!
                        UIPasteboard.general.string = json
                    }.buttonStyle(PillButtonStyle(background: Color.primary.opacity(0.2)))
                }
            }.tabItem { Text("Editor") }
        }.statusBar(hidden: true)
    }
}
