//
//  PenballEditorBallView.swift
//  PenballEditor
//
//  Created by Anthony Li on 4/18/21.
//

import SwiftUI

struct EditorBallView: View {
    enum Style {
        case filled
        case stroked
    }
    
    var style: Style
    var color: Color
    var isFaded: Bool
    var onTapGesture: () -> Void
    
    var shape: AnyView {
        let circle = Circle().size(CGSize(width: 44, height: 44))
        switch style {
        case .filled:
            return AnyView(circle.fill(color))
        case .stroked:
            return AnyView(ZStack {
                circle.fill(Color.black.opacity(0.2))
                circle.stroke(color, lineWidth: 2)
            }.frame(width: 44, height: 44).drawingGroup())
        }
    }
    
    var body: some View {
        shape.fixedSize(horizontal: true, vertical: true).onTapGesture {
            onTapGesture()
        }.allowsHitTesting(!isFaded).animation(nil).opacity(isFaded ? 0.2 : 1).animation(.easeInOut).frame(alignment: .center)
    }
}
