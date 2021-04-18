//
//  GameControls.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI
import PencilKit

struct GameControls: View {
    var level: Level
    var timerText: String
    @Binding var state: PenballState
    @Binding var tool: PKTool
    @Binding var strokes: [Double: PKStroke]
    @State var showingClearPopover = false
    
    var body: some View {
        HStack {
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
                    }).buttonStyle(PillButtonStyle(background: Color.white)).disabled(strokes.isEmpty).popover(isPresented: $showingClearPopover, content: {
                        ClearPopover {
                            showingClearPopover = false
                        } onClear: {
                            strokes = [:]
                            tool = PenballCanvasView.defaultTool
                            showingClearPopover = false
                        }
                    })
                }.frame(maxWidth: .infinity)
            }
        }.padding(.top, 8).padding(.horizontal, 24).padding(.bottom, 32).frame(alignment: .center).animation(nil).opacity((state == .completed || state == .transitioning) ? 0 : 1).animation(state == .transitioning ? nil : .easeInOut(duration: state == .notStarted ? 0.25 : 0.75))
    }
}
