//
//  PenballView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/15/21.
//

import SwiftUI
import PencilKit

public struct PenballLevelView: View {
    let deathMessage = ["Oh no!"].randomElement()!
    
    @Binding var strokes: [Double: PKStroke]
    @Binding var tool: PKTool
    @Binding var state: PenballState
    @State var timerText = ""
    @State var showingClearPopover = false
    
    var level: Level
    var onContinue: (() -> Void)?
    
    var scene: PenballScene {
        level.scene
    }
    
    public init(_ level: Level, strokes: Binding<[Double: PKStroke]>, tool: Binding<PKTool>, state: Binding<PenballState>, onContinue: (() -> Void)? = nil) {
        self.level = level
        self._strokes = strokes
        self._tool = tool
        self._state = state
        self.onContinue = onContinue
    }
    
    public var body: some View {
        ZStack {
            PenballSpriteView(scene: scene, strokes: strokes, state: $state, timerText: $timerText)
            if level.allowsDrawing {
                PenballCanvasView(strokes: $strokes, tool: $tool).environment(\.colorScheme, .light).animation(nil).opacity(state == .transitioning ? 0 : 1).animation(state == .transitioning ? .easeInOut(duration: 0.75) : nil)
            }
            VStack(spacing: 0) {
                Spacer()
                HintView(content: deathMessage, secondaryContent: "Tap below to restart", visible: state == .failed)
                ZStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Level complete!").bold().font(.largeTitle)
                            if level.allowsDrawing {
                                HStack(spacing: 8) {
                                    Text("Time: \(timerText)")
                                    // Text("Best: 00:00").opacity(0.6)
                                }
                                HStack(spacing: 8) {
                                    Text("Strokes: \(strokes.count)")
                                    // Text("New Best!").foregroundColor(.yellow).bold()
                                }
                            }
                        }
                        Spacer()
                        Button {
                            state = .notStarted
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry").fontWeight(.bold)
                            }.padding().foregroundColor(Color.black)
                        }.buttonStyle(PillButtonStyle(background: Color.white))
                        if let onContinue = onContinue {
                            Button {
                                state = .transitioning
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    onContinue()
                                }
                            } label: {
                                HStack {
                                    Text("Continue").fontWeight(.bold)
                                    Image(systemName: "arrow.right")
                                }.padding().foregroundColor(Color.white)
                            }.buttonStyle(PillButtonStyle(background: Color.green))
                        }
                    }.padding(24).animation(nil).opacity(state == .completed ? 1 : 0).animation(.easeInOut(duration: state == .notStarted ? 0.25 : 0.75))
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
                                state = state == .notStarted ? .started : .notStarted
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
                    }.padding(24).padding(.bottom, 8).frame(alignment: .center).animation(nil).opacity((state == .completed || state == .transitioning) ? 0 : 1).animation(.easeInOut(duration: state == .notStarted ? 0.25 : 0.75))
                }.background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), .clear]), startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0)))
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea().statusBar(hidden: true)
    }
}
