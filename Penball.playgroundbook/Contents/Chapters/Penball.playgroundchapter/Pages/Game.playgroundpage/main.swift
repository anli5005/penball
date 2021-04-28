//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//

import PlaygroundSupport
import SwiftUI
import PencilKit

var levels = [Level]()

// Adds a level from a given file.
func addLevel(name: String, file: String, allowsDrawing: Bool = true) {
    let data = try! Data(contentsOf: Bundle.main.url(forResource: file, withExtension: "json")!)
    let level = Level(id: name, from: try! JSONDecoder().decode(LevelDefinition.self, from: data), allowsDrawing: allowsDrawing)
    levels.append(level)
}

//#-end-hidden-code

/*:
 Welcome to Penball! Penball is a game about manipulating balls by drawing. Run the playground, then press Start to get started.
 
 This game is best played with an Apple Pencil.
 
 A few tips:
 * You can jump between levels using the level selector on the top-right corner.
 * Don't forget to switch back to the pen once you're done erasing.
 * Double-tapping with the Apple Pencil (2nd generation) toggles between the pen and the eraser.
 * You can edit your drawings even after you start the level.
 
 This game uses a 517 × 580 game window; if it doesn't fit in the live view, make the live view full screen and turn your device into a portrait orientation.
 */

addLevel(name: "Intro", file: "level1", allowsDrawing: false)
addLevel(name: "Tutorial", file: "level2")
addLevel(name: "Bridging the Gap", file: "level3")
addLevel(name: "Don't touch red!", file: "level4")
addLevel(name: "Tunnel", file: "level5")
addLevel(name: "Bouncy", file: "level6")
addLevel(name: "Elevator", file: "level7")
addLevel(name: "Multiple Balls", file: "level8")
addLevel(name: "WWDC", file: "level9")
addLevel(name: "Stack", file: "level10")
addLevel(name: "Shuffle", file: "level11")

//#-hidden-code
struct ContentView: View {
    @State var bests = [String: Score]()
    
    var body: some View {
        // Letterbox the view with dark gray.
        PenballView(levels: levels, bests: $bests).frame(width: 517, height: 580, alignment: .center).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(white: 0.1))
    }
}

let hostingController = UIHostingController(rootView: ContentView())
hostingController.preferredContentSize = CGSize(width: 517, height: 580)
PlaygroundPage.current.setLiveView(hostingController)
//#-end-hidden-code
