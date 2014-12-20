[![Build Status](https://secure.travis-ci.org/AriaMinaei/theatrejs-bezierpacs.png)](http://travis-ci.org/AriaMinaei/theatrejs-bezierpacs)

This is gonna be a rewrite of the [old pacs](https://github.com/AriaMinaei/theatrejs/blob/0.1/scripts/coffee/lib/dynamicTimeline/prop/Pacs.coffee).

Features missing from the old pacs:

- [x] Undo/redo and a complete history
- [x] Ability to drag points in time, see the results in real time, and cancel the drag
- [x] Ability to drag selections in time, see the results in real time, scale em, etc.
- [x] Keep keyframe values in basic units and not in milliseconds
- [ ] Stack-based animation instead of calling each prop on every frame (might not be necessary for 0.2)