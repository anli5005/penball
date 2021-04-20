import SwiftUI
#if DEBUG
import SpriteKit
#endif

// Level selector, displayed in a popover.
struct LevelSelect: View {
    // Parameters from PenballView.
    var levels: [Level]
    var bests: [String: Score]
    var currentLevel: Int
    
    // Function called when a level is selected.
    var levelSelected: (Int) -> Void
    
    // Index of the first uncompleted level.
    var nextLevel: Int
    
    init(levels: [Level], bests: [String: Score], currentLevel: Int, levelSelected: @escaping (Int) -> Void) {
        self.levels = levels
        self.bests = bests
        self.currentLevel = currentLevel
        self.levelSelected = levelSelected
        
        self.nextLevel = levels.firstIndex(where: { bests[$0.id] == nil }) ?? levels.endIndex
    }
    
    // Fetches the best scores for a level of a given index.
    func bests(for index: Int) -> Score? {
        bests[levels[index].id]
    }
    
    // Computes the background color to use when drawing a level with a given index.
    func backgroundColor(for index: Int) -> Color {
        if bests(for: index) != nil {
            return Color.green
        } else if index == nextLevel {
            return Color.blue
        } else {
            return Color.gray
        }
    }
    
    // Computes the foreground color to use when drawing a level with a given index.
    func foregroundColor(for index: Int) -> Color {
        if bests(for: index) != nil {
            return Color.white
        } else if index == nextLevel {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Level Select").bold().font(.largeTitle).bold().padding()
                LazyVGrid(columns: [GridItem(.fixed(72), alignment: .top), GridItem(.fixed(72), alignment: .top), GridItem(.fixed(72), alignment: .top)]) {
                    ForEach(0..<levels.count) { index in
                        Button {
                            if index != currentLevel {
                                levelSelected(index)
                            }
                        } label: {
                            VStack(spacing: 2) {
                                // Circle with level number
                                ZStack {
                                    Circle().size(CGSize(width: 60, height: 60)).fill(backgroundColor(for: index))
                                    if index == currentLevel {
                                        Circle().size(CGSize(width: 60, height: 60)).stroke(Color.primary, lineWidth: 4)
                                    }
                                    Text("\(index + 1)").bold().font(.title2).foregroundColor(foregroundColor(for: index))
                                }.frame(width: 60, height: 60)
                                
                                // Level name
                                Text(levels[index].name).font(.caption).multilineTextAlignment(.center).foregroundColor(Color.primary)
                                
                                // Best scores, if any
                                if let bests = bests(for: index) {
                                    Text("\(bests.timeString!) • \(bests.strokes)").font(.caption2).multilineTextAlignment(.center).foregroundColor(Color.primary).opacity(0.8)
                                }
                            }.padding(.vertical, 6)
                        }
                    }
                }.fixedSize(horizontal: true, vertical: false).padding([.horizontal, .bottom])
            }
        }.frame(maxHeight: 500)
    }
}

#if DEBUG
struct LevelSelectPreviewProvider: PreviewProvider {
    static var previews: some View {
        LevelSelect(levels: [
            Level(id: "Test 1", scene: PenballScene()),
            Level(id: "Test 2", scene: PenballScene()),
            Level(id: "Test 3", scene: PenballScene()),
            Level(id: "Test 4", scene: PenballScene()),
            Level(id: "Test 5", scene: PenballScene()),
            Level(id: "Test 6", scene: PenballScene())
        ], bests: ["Test 1": Score(time: 0, strokes: 0)], currentLevel: 0, levelSelected: { _ in }).previewLayout(.sizeThatFits)
        
        LevelSelect(levels: [
            Level(id: "Test 1", scene: PenballScene()),
            Level(id: "Test 2", scene: PenballScene()),
            Level(id: "Test 3", scene: PenballScene()),
            Level(id: "Test 4", scene: PenballScene()),
            Level(id: "Test 5", scene: PenballScene()),
            Level(id: "Test 6", scene: PenballScene())
        ], bests: ["Test 1": Score(time: 0, strokes: 0)], currentLevel: 0, levelSelected: { _ in }).previewLayout(.sizeThatFits).background(Color.black).environment(\.colorScheme, .dark)
    }
}
#endif
