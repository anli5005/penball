import SwiftUI
import PencilKit

// View that manages the Penball game.
public struct PenballView: View {
    // Array of levels to display.
    var levels: [Level]
    
    // Mapping of level IDs to best scores.
    @Binding var bests: [String: Score]
    
    // Index of the current level.
    @State var currentLevel: Int = 0
    
    // Parameters for the current level.
    @State var drawing = PKDrawing()
    @State var state = PenballState.notStarted
    @State var tool: PKTool = PenballCanvasView.defaultTool
    
    @State var showingLevelSelect = false
    
    public init(levels: [Level], bests: Binding<[String: Score]>) {
        self.levels = levels
        self._bests = bests
    }
    
    // Transitions to the level with a given index.
    func transition(to index: Int) {
        drawing = PKDrawing()
        tool = PenballCanvasView.defaultTool
        currentLevel = index
        DispatchQueue.main.asyncAfter(deadline: .now() + PenballSpriteView.transitionTime) {
            state = .notStarted
        }
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            PenballLevelView(levels[currentLevel], drawing: $drawing, tool: $tool, state: $state, bests: $bests, onContinue: currentLevel == levels.endIndex - 1 ? nil : {
                transition(to: currentLevel + 1)
            })
            
            Button {
                showingLevelSelect = true
            } label: {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Levels").bold()
                }.foregroundColor(.black)
            }.buttonStyle(PillButtonStyle(background: Color.white)).disabled(state == .transitioning).padding([.top, .trailing], 24).popover(isPresented: $showingLevelSelect, content: {
                LevelSelect(levels: levels, bests: bests, currentLevel: currentLevel) { index in
                    if state != .transitioning {
                        state = .transitioning
                        showingLevelSelect = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            transition(to: index)
                        }
                    }
                }
            })
        }
    }
}
