import SwiftUI
import UIKit

// View that captures taps and reports their location.
struct EditorTapView: UIViewRepresentable {
    class TapViewContent: UIView {
        weak var coordinator: Coordinator?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.backgroundColor = CGColor(gray: 0, alpha: 0.8)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first {
                coordinator?.tap(at: touch.location(in: self))
            }
        }
    }
    
    // Called with the location of a tap when a tap occurs.
    let onUpdate: (CGPoint) -> Void
    
    func makeUIView(context: Context) -> TapViewContent {
        let view = TapViewContent()
        view.coordinator = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: TapViewContent, context: Context) {
        context.coordinator.parent = self
        uiView.coordinator = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        var parent: EditorTapView
        
        init(_ parent: EditorTapView) {
            self.parent = parent
        }
        
        func tap(at position: CGPoint) {
            parent.onUpdate(position)
        }
    }
}
