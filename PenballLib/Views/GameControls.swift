//
//  GameControls.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI
import PencilKit

// View displaying the controls for the game.
struct GameControls: View {
    // Current level.
    var level: Level
    
    // Text drawn on the reset button, displaying the time elapsed after the level starts.
    var timerText: String
    
    // Binding to the state of the level.
    @Binding var state: PenballState
    
    // Binding to the current tool.
    @Binding var tool: PKTool
    
    // Binding to the drawing on the level.
    @Binding var drawing: PKDrawing
    
    @State var showingClearPopover = false
    
    var body: some View {
        HStack {
            // Pen/Eraser
            if level.allowsDrawing {
                HStack {
                    Button(action: {
                        tool = PenballCanvasView.defaultTool
                    }, label: {
                        Image(systemName: "pencil").accessibilityLabel("Pen").foregroundColor(tool is PKEraserTool ? Color.black : Color.white).frame(width: 40 - 2 * 8)
                    }).buttonStyle(PillButtonStyle(background: tool is PKEraserTool ? Color.white : Color.blue))
                    Button(action: {
                        tool = PKEraserTool(.vector)
                    }, label: {
                        Image(systemName: "xmark").accessibilityLabel("Eraser").foregroundColor(tool is PKEraserTool ? Color.white : Color.black).frame(width: 40 - 2 * 8)
                    }).buttonStyle(PillButtonStyle(background: tool is PKEraserTool ? Color.blue : Color.white))
                    Spacer()
                }.frame(maxWidth: .infinity)
            }
            
            // Start/Reset
            HStack {
                Button(action: {
                    state = (state == .notStarted) ? .started : .notStarted
                }, label: {
                    if state == .notStarted {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start").fontWeight(.bold)
                        }.padding().foregroundColor(Color.white).frame(minWidth: 120)
                    } else {
                        HStack {
                            Image(systemName: "arrow.clockwise").accessibilityLabel("Reset")
                            Text(timerText).fontWeight(.bold)
                        }.padding().foregroundColor(Color.white).frame(minWidth: 120)
                    }
                }).buttonStyle(PillButtonStyle(background: state == .notStarted ? Color.green : Color.blue)).disabled(state == .completed)
            }.frame(maxWidth: .infinity)
            
            // Clear
            if level.allowsDrawing {
                HStack {
                    Spacer()
                    Button(action: {
                        showingClearPopover = true
                    }, label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear").fontWeight(.bold)
                        }.foregroundColor(Color.red)
                    }).buttonStyle(PillButtonStyle(background: Color.white)).disabled(drawing.strokes.isEmpty).popover(isPresented: $showingClearPopover, content: {
                        ClearPopover {
                            showingClearPopover = false
                        } onClear: {
                            drawing = PKDrawing()
                            tool = PenballCanvasView.defaultTool
                            showingClearPopover = false
                        }
                    })
                }.frame(maxWidth: .infinity)
            }
        }.padding(.top, 8).padding(.bottom, 16).padding(.horizontal, 24).frame(alignment: .center).animation(nil).opacity((state == .completed || state == .transitioning) ? 0 : 1).animation(state == .transitioning ? nil : .easeInOut(duration: state == .notStarted ? 0.25 : 0.75))
    }
}
