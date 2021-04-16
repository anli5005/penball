//
//  PenballCanvasView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/16/21.
//

import SwiftUI
import PencilKit

struct PenballCanvasView: UIViewRepresentable {
    @Binding var strokes: [Double: PKStroke]
    @Binding var tool: PKTool
    
    static let defaultTool = PKInkingTool(.pen, color: .init(white: 1, alpha: 0.7), width: 10)
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let view = PKCanvasView()
        view.backgroundColor = .clear
        view.tool = tool
        view.drawingPolicy = .anyInput
        
        context.coordinator.parent = self
        context.coordinator.canvasView = view
        
        view.delegate = context.coordinator
        
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = context.coordinator
        view.addInteraction(pencilInteraction)
                
        return view
    }
    
    func updateUIView(_ view: PKCanvasView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.canvasView = view
        
        view.delegate = context.coordinator
        view.tool = tool
        
        if let interaction = view.interactions.first(where: { $0 is UIPencilInteraction }) as? UIPencilInteraction {
            interaction.delegate = context.coordinator
        }
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, UIPencilInteractionDelegate {
        init(parent: PenballCanvasView) {
            self.parent = parent
        }
        
        var parent: PenballCanvasView
        weak var canvasView: PKCanvasView?
        
        func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
            if parent.tool is PKEraserTool {
                parent.tool = PenballCanvasView.defaultTool
            } else {
                parent.tool = PKEraserTool(.vector)
            }
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let strokes = canvasView.drawing.strokes
            if let index = (0..<strokes.count).max(by: { strokes[$0].path.creationDate < strokes[$1].path.creationDate }) {
                if strokes[index].ink.color.cgColor.alpha != 1 {
                    canvasView.drawing.strokes[index].ink.color = strokes[index].ink.color.withAlphaComponent(1)
                    return
                }
            }
            
            parent.strokes = [Double: PKStroke](uniqueKeysWithValues: canvasView.drawing.strokes.map { stroke in
                return (stroke.path.creationDate.timeIntervalSince1970, stroke)
            })
        }
    }
}
