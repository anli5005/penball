import SwiftUI
import PencilKit

// View that encapsulates a PencilKit canvas.
public struct PenballCanvasView: UIViewRepresentable {
    // Binding to the drawing on the canvas.
    @Binding var drawing: PKDrawing
    
    // Current tool.
    var tool: PKTool
    
    // Whether the canvas sets the opacity of each completed stroke to 1.
    var updateStrokeAlpha: Bool
    
    // Function called when a 2nd-generation Apple Pencil is double-tapped.
    var onPencilInteraction: () -> Void
    
    // Function called when the drawing updates.
    var onUpdate: () -> Void
    
    public init(drawing: Binding<PKDrawing>, tool: PKTool, updateStrokeAlpha: Bool = true, onPencilInteraction: @escaping () -> Void = {}, onUpdate: @escaping () -> Void = {}) {
        _drawing = drawing
        self.tool = tool
        self.updateStrokeAlpha = updateStrokeAlpha
        self.onPencilInteraction = onPencilInteraction
        self.onUpdate = onUpdate
    }
    
    // Default tool (the pen) for drawing obstacles.
    public static let defaultTool = PKInkingTool(.pen, color: .init(white: 1, alpha: 0.7), width: 10)
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIView(context: Context) -> PKCanvasView {
        let view = PKCanvasView()
        view.overrideUserInterfaceStyle = .light
        view.backgroundColor = .clear
        view.tool = tool
        view.drawingPolicy = .anyInput
        
        context.coordinator.parent = self
        context.coordinator.canvasView = view
        
        view.delegate = context.coordinator
        context.coordinator.isUndergoingStateUpdate = true
        view.drawing = drawing
        context.coordinator.isUndergoingStateUpdate = false
        
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = context.coordinator
        view.addInteraction(pencilInteraction)
                
        return view
    }
    
    public func updateUIView(_ view: PKCanvasView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.canvasView = view
        
        view.delegate = context.coordinator
        view.tool = tool
        context.coordinator.isUndergoingStateUpdate = true
        if view.drawing != drawing {
            view.drawing = drawing
        }
        context.coordinator.isUndergoingStateUpdate = false
        
        if let interaction = view.interactions.first(where: { $0 is UIPencilInteraction }) as? UIPencilInteraction {
            interaction.delegate = context.coordinator
        }
    }
    
    public class Coordinator: NSObject, PKCanvasViewDelegate, UIPencilInteractionDelegate {
        init(parent: PenballCanvasView) {
            self.parent = parent
        }
        
        var parent: PenballCanvasView
        var isUndergoingStateUpdate = false
        weak var canvasView: PKCanvasView?
        
        public func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
            parent.onPencilInteraction()
        }
        
        public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if isUndergoingStateUpdate {
                return
            }
            
            if parent.updateStrokeAlpha {
                // Set the opacity of the latest stroke to 100%.
                var drawing = canvasView.drawing
                let strokes = drawing.strokes
                if let index = (0..<strokes.count).max(by: { strokes[$0].path.creationDate < strokes[$1].path.creationDate }) {
                    if strokes[index].ink.color.cgColor.alpha != 1 {
                        drawing.strokes[index].ink.color = strokes[index].ink.color.withAlphaComponent(1)
                    }
                }
                parent.drawing = drawing
            } else {
                parent.drawing = canvasView.drawing
            }
            
            parent.onUpdate()
        }
    }
}
