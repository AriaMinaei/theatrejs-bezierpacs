# theatrejs-bezierpacs

This is gonna be a rewrite of the [old pacs](https://github.com/AriaMinaei/theatrejs/blob/0.1/scripts/coffee/lib/dynamicTimeline/prop/Pacs.coffee)

### Features missing from the old pacs

* Undo/redo and a complete history
* Ability to drag points in time, see the results in real time, and cancel the drag
* Ability to drag selections in time, see the results in real time, scale em, etc.
* Keep keyframe values in basic units and not in milliseconds
* Stack-based animation instead of calling each prop on every frame (might not be necessary for 0.2)