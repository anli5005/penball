//
//  ClearPopover.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI

// Popover that confirms whether the user wants to clear the drawing.
struct ClearPopover: View {
    var onCancel: () -> Void
    var onClear: () -> Void
    
    var body: some View {
        VStack {
            Text("Are you sure?")
            HStack {
                // Button scale animations display weird behavior in popovers, so we disable them
                Button(action: {
                    onCancel()
                }, label: {
                    Text("Cancel").bold().padding().foregroundColor(.primary)
                }).buttonStyle(PillButtonStyle(background: Color.primary.opacity(0.1), animatesScale: false))
                Button(action: {
                    onClear()
                }, label: {
                    Text("Clear").bold().padding().foregroundColor(.white)
                }).buttonStyle(PillButtonStyle(background: Color.red, animatesScale: false))
            }
        }.padding()
    }
}

#if DEBUG
struct ClearPopoverPreviews: PreviewProvider {
    static var previews: some View {
        ClearPopover(onCancel: {}, onClear: {}).padding()
    }
}
#endif
