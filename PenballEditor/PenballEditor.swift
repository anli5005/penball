//
//  PenballEditor.swift
//  PenballEditor
//
//  Created by Anthony Li on 4/18/21.
//

import SwiftUI
import PenballLib
import PencilKit

extension Color {
    var uiColor: UIColor? {
        cgColor.map { UIColor(cgColor: $0) }
    }
}

public struct PenballEditor: View {
    enum Tool: CaseIterable {
        case pen
        case marker
        case pencil
        case bitmapEraser
        case vectorEraser
        
        var name: String {
            switch self {
            case .pen:
                return "Pen"
            case .marker:
                return "Marker"
            case .pencil:
                return "Pencil"
            case .bitmapEraser:
                return "Bitmap Eraser"
            case .vectorEraser:
                return "Vector Eraser"
            }
        }
        
        func alternativeTool(for object: ObjectType) -> Tool {
            switch object {
            case .none:
                return self
            default:
                switch self {
                case .bitmapEraser, .vectorEraser:
                    return .vectorEraser
                default:
                    return .pen
                }
            }
        }
    }
    
    public enum ObjectType: CaseIterable {
        case none
        case obstacle
        case hazard
        case bouncePad
        
        var name: String {
            switch self {
            case .none:
                return "Background"
            case .obstacle:
                return "Obstacle"
            case .hazard:
                return "Hazard"
            case .bouncePad:
                return "Bounce Pad"
            }
        }
        
        public var category: PenballObjectType? {
            switch self {
            case .none:
                return nil
            case .obstacle:
                return .preloadedObstacle
            case .hazard:
                return .hazard
            case .bouncePad:
                return .bouncePad
            }
        }
    }
    
    public struct Ball: Identifiable {
        public let id = UUID()
        public var color: Color
        public var start: CGPoint
        public var end: CGPoint
    }
    
    @Binding var drawing: PKDrawing
    @Binding var strokeTypes: [Double: ObjectType]
    @Binding var balls: [Ball]
    
    @State var penColor = Color.white
    @State var markerColor = Color.white
    @State var pencilColor = Color.white
    
    @State var penWidth: CGFloat = 5
    @State var markerWidth: CGFloat = 5
    @State var pencilWidth: CGFloat = 5
    
    @State var tool = Tool.pen
    @State var objectType = ObjectType.none
    
    @State var showingBallsPopover = false
    @State var selectedBall: Int?
    @State var selectedPoint: WritableKeyPath<Ball, CGPoint> = \.start
    
    var pkTool: PKTool {
        switch tool {
        case .pen:
            return PKInkingTool(.pen, color: penColor.uiColor ?? .white, width: penWidth)
        case .marker:
            return PKInkingTool(.marker, color: markerColor.uiColor ?? .white, width: markerWidth)
        case .pencil:
            return PKInkingTool(.pencil, color: pencilColor.uiColor ?? .white, width: pencilWidth)
        case .bitmapEraser:
            return PKEraserTool(.bitmap)
        case .vectorEraser:
            return PKEraserTool(.vector)
        }
    }
    
    var colorBinding: Binding<Color> {
        switch tool {
        case .pen:
            return $penColor
        case .marker:
            return $markerColor
        case .pencil:
            return $pencilColor
        case .bitmapEraser, .vectorEraser:
            return Binding.constant(.clear)
        }
    }
    
    var widthBinding: Binding<CGFloat> {
        switch tool {
        case .pen:
            return $penWidth
        case .marker:
            return $markerWidth
        case .pencil:
            return $pencilWidth
        case .bitmapEraser, .vectorEraser:
            return Binding.constant(0)
        }
    }
    
    public init(drawing: Binding<PKDrawing>, strokeTypes: Binding<[Double: ObjectType]>, balls: Binding<[Ball]>) {
        _drawing = drawing
        _strokeTypes = strokeTypes
        _balls = balls
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                PenballCanvasView(drawing: $drawing, tool: pkTool, updateStrokeAlpha: false, onUpdate: {
                    drawing.strokes.map(\.path.creationDate.timeIntervalSince1970).filter { strokeTypes[$0] == nil }.forEach { strokeTypes[$0] = objectType }
                }).environment(\.colorScheme, .light)
                EditorTapView { point in
                    if let index = selectedBall {
                        balls[index][keyPath: selectedPoint] = CGPoint(x: point.x, y: geometry.size.height - point.y)
                        selectedBall = nil
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity).animation(nil).opacity(selectedBall == nil ? 0 : 1 ).animation(.easeInOut)
                ZStack(alignment: .topLeading) {
                    ForEach(Array(balls.enumerated()), id: \.element.id) { item in
                        EditorBallView(style: .filled, color: item.element.color, isFaded: selectedBall != nil && (selectedBall != item.offset || selectedPoint != \.start)) {
                            if selectedBall == item.offset && selectedPoint == \.start {
                                selectedBall = nil
                            } else {
                                selectedBall = item.offset
                                selectedPoint = \.start
                            }
                        }.position(x: item.element.start.x - 10, y: geometry.size.height - item.element.start.y - 10)
                        EditorBallView(style: .stroked, color: item.element.color, isFaded: selectedBall != nil && (selectedBall != item.offset || selectedPoint != \.end)) {
                            if selectedBall == item.offset && selectedPoint == \.end {
                                selectedBall = nil
                            } else {
                                selectedBall = item.offset
                                selectedPoint = \.end
                            }
                        }.position(x: item.element.end.x - 10, y: geometry.size.height - item.element.end.y - 10)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity).environment(\.layoutDirection, .leftToRight)
                HStack {
                    HStack {
                        Menu {
                            ForEach(Tool.allCases.filter { $0.alternativeTool(for: objectType) == $0 }, id: \.self) { tool in
                                Button(tool.name) {
                                    self.tool = tool
                                }
                            }
                        } label: {
                            Text(tool.name).frame(width: 150, alignment: .leading).foregroundColor(.white)
                        }
                        Spacer()
                    }.frame(maxWidth: .infinity)
                    HStack {
                        Menu {
                            ForEach(ObjectType.allCases, id: \.self) { objectType in
                                Button(objectType.name) {
                                    self.objectType = objectType
                                    tool = tool.alternativeTool(for: objectType)
                                }
                            }
                        } label: {
                            Text(objectType.name).frame(width: 150).foregroundColor(.white)
                        }
                    }.frame(maxWidth: .infinity)
                    HStack {
                        Spacer()
                        Button {
                            showingBallsPopover = true
                        } label: {
                            Text("Balls").foregroundColor(.white)
                        }.popover(isPresented: $showingBallsPopover, content: {
                            List(balls.enumerated().map { ($0.offset, $0.element.id) }, id: \.1) { item in
                                ColorPicker("Ball #\(item.0 + 1)", selection: $balls[item.0].color)
                            }.frame(width: 200, height: 200)
                            Divider()
                            Button("Add Ball") {
                                balls.append(Ball(color: .white, start: CGPoint(x: geometry.size.width / 2 - 50, y: geometry.size.height / 2 + 50), end: CGPoint(x: geometry.size.width / 2 + 50, y: geometry.size.height / 2 - 50)))
                            }.padding(4)
                        })
                        Slider(value: widthBinding, in: 1...50).disabled(pkTool is PKEraserTool).frame(width: 100)
                        ColorPicker(selection: colorBinding) {
                            EmptyView()
                        }.aspectRatio(1, contentMode: .fit).accessibilityLabel("Color").disabled(pkTool is PKEraserTool)
                    }.frame(maxWidth: .infinity)
                }.padding().frame(maxWidth: .infinity).background(Color.black.opacity(0.5))
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.black)
        }
    }
}
