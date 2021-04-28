import SwiftUI
import PencilKit
import PenballLib

// View responsible for supporting level editing and playtesting.
struct EditorContentView: View {
    // State of the level being edited.
    @State var drawing = PKDrawing()
    @State var strokeTypes = [Double: PenballEditor.ObjectType]()
    @State var balls = [PenballEditor.Ball]()
    
    // Level being playtested. Nil if not in playtesting mode.
    @State var level: Level? = nil
    
    // Best scores.
    @State var bests = [String: Score]()
    
    // State of the level being playtested.
    @State var playtestDrawing = PKDrawing()
    @State var playtestTool: PKTool = PenballCanvasView.defaultTool
    @State var playtestState = PenballState.notStarted
    
    // Generates a LevelDefinition from the level's current state.
    func generateLevel() -> LevelDefinition {
        LevelDefinition(drawing: drawing, strokeTypes: strokeTypes, balls: balls, sceneHeight: 580)
    }
    
    var body: some View {
        return level == nil ? AnyView(editorBody) : AnyView(playtestBody)
    }
    
    // Body that appears in playtesting mode.
    var playtestBody: some View {
        ZStack {
            PenballLevelView(level!, drawing: $playtestDrawing, tool: $playtestTool, state: $playtestState, bests: $bests).frame(width: 517, height: 580)
            Button {
                level = nil
            } label: {
                Text("Done").bold().padding().foregroundColor(.black)
            }.buttonStyle(PillButtonStyle(background: Color.white)).padding().frame(width: 517, height: 580, alignment: .topTrailing)
        }
    }
    
    // Body that appears in editing mode.
    var editorBody: some View {
        ZStack {
            // The actual editor
            PenballEditor(drawing: $drawing, strokeTypes: $strokeTypes, balls: $balls).frame(width: 517, height: 580)
            
            HStack {
                // Copy JSON to clipboard
                // Used extensively while making the base game
                Button {
                    let level = generateLevel()
                    let encoder = JSONEncoder()
                    let json = try! String(data: encoder.encode(level), encoding: .utf8)!
                    UIPasteboard.general.string = json
                } label: {
                    Text("Copy JSON").foregroundColor(.black).bold().padding()
                }.buttonStyle(PillButtonStyle(background: Color.white))
                
                // Enter playtesting mode
                Button {
                    playtestDrawing = PKDrawing()
                    playtestTool = PenballCanvasView.defaultTool
                    playtestState = .notStarted
                    level = Level(id: UUID().uuidString, from: generateLevel())
                } label: {
                    Text("Play").foregroundColor(.white).bold().padding()
                }.buttonStyle(PillButtonStyle(background: Color.blue))
            }.padding().frame(width: 517, height: 580, alignment: .topTrailing)
        }
    }
}

public func makeEditor() -> UIHostingController<AnyView> {
    // Letterbox the view.
    let hostingController = UIHostingController(rootView: AnyView(EditorContentView().frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(white: 0.1))))
    hostingController.preferredContentSize = CGSize(width: 517, height: 580)
    return hostingController
}
