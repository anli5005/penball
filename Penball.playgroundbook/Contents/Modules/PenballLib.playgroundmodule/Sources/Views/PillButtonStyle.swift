//
//  PillButtonStyle.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI

// Button style used throughout Penball.
public struct PillButtonStyle<Background: View>: ButtonStyle {
    // Background of the button.
    var background: Background
    
    // Whether the size of the button animates when pressed. Used in ClearPopover.
    var animatesScale: Bool
    
    struct Content<Background: View>: View {
        var configuration: Configuration
        var background: Background
        @Environment(\.isEnabled) var isEnabled: Bool
        
        var opacity: Double {
            if !isEnabled {
                return 0.3
            } else if configuration.isPressed {
                return 0.8
            } else {
                return 1
            }
        }
        
        var body: some View {
            configuration.label.padding(.horizontal, 8).frame(height: 40).background(background).cornerRadius(20).shadow(radius: 5).textCase(.uppercase).animation(nil).opacity(opacity).animation(.easeInOut(duration: 0.1))
        }
    }
    
    public init(background: Background, animatesScale: Bool = true) {
        self.background = background
        self.animatesScale = animatesScale
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        Content(configuration: configuration, background: background).animation(nil).scaleEffect((configuration.isPressed && animatesScale) ? 0.9 : 1).animation(animatesScale ? .easeInOut(duration: 0.1) : nil)
    }
}

#if DEBUG
struct PillButtonPreviewProvider: PreviewProvider {
    static var previews: some View {
        Button("Test") {}.buttonStyle(PillButtonStyle(background: Color.primary.opacity(0.1)))
    }
}
#endif
