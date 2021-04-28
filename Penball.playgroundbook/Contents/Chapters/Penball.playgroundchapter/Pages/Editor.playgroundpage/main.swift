//#-hidden-code

import PlaygroundSupport

//#-end-hidden-code

/*:
 This is a rudimentary level editor, used to create all the levels in the base game. You can use it to make your own levels, too!
 
 Along the bottom you'll find controls for creating your level. From left to right, these are:
 * **Balls** - Add balls and change their colors.
 * **Tool Picker** - Switch between pens and erasers.
 * **Object Picker** - Pick the type of object you're currently drawing.
    * **Background** objects are purely decorative.
    * **Obstacles** interact and collide with the ball. As a part of the level, they cannot be erased by the player.
    * **Hazards** destroy balls they come into contact with.
    * **Bounce Pads** launch balls into the air.
 * **Width & Color** - Configure the line width and color that you're using to draw.
 
 To edit a ball, add it first using the **Balls** button. Then tap on one of the points that appears. Once the rest of the level dims, tap where you want to put it.
 
 Once you're down, you can press **Play** to playtest your level, or press **Copy JSON** to obtain its JSON representation.
 
 To start over, stop and re-run the playground.
 */

PlaygroundPage.current.setLiveView(makeEditor())
 
