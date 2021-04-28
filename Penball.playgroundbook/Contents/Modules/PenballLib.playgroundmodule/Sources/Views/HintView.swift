//
//  HintView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI

// View that appears when the level is failed, to provide a hint to the user that they should press the Reset button.
struct HintView: View {
    var content: String
    var secondaryContent: String? = nil
    var visible: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(content).multilineTextAlignment(.center).foregroundColor(Color.black)
            if let text = secondaryContent {
                Text(text).foregroundColor(Color.gray).font(.subheadline)
            }
        }.padding().background(Color.white).cornerRadius(10).frame(maxWidth: 256).shadow(radius: 5).animation(nil).scaleEffect(visible ? 1 : 0.9).opacity(visible ? 1 : 0).animation(.easeInOut(duration: 0.3))
    }
}

#if DEBUG
struct HintViewPreviews: PreviewProvider {
    static var previews: some View {
        HintView(content: "This is a test hint view with really long text! Very long! aaaaaaaaaaaaaaaaa", secondaryContent: "Tap here to continue", visible: true).padding()
    }
}
#endif
