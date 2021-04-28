import PenballLib
import PencilKit

public extension LevelDefinition {
    // Initializes a level definition from the corresponding PenballEditor data types. Used when exporting a level from the editor.
    init(drawing: PKDrawing, strokeTypes: [Double: PenballEditor.ObjectType], balls: [PenballEditor.Ball], sceneHeight: CGFloat) {
        self.init(drawing: drawing, strokeTypes: Dictionary(uniqueKeysWithValues: strokeTypes.compactMap { entry in
            entry.value.category.map { (entry.key, $0) }
        }), balls: balls.map { ball in
            var red: CGFloat = 1
            var green: CGFloat = 1
            var blue: CGFloat = 1
            ball.color.uiColor?.getRed(&red, green: &green, blue: &blue, alpha: nil)
            return LevelDefinition.Ball(start: ball.start, end: ball.end, color: (red, green, blue))
        }, sceneHeight: sceneHeight)
    }
}
