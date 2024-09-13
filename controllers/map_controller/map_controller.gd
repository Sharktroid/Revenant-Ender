## Autoload that manages and interfaces for the current [Map].
extends Control

## The currently active [Map].
var map := Map.new()


## Returns the [CanvasLayer] containing the Map's UI.
func get_ui() -> CanvasLayer:
	var path := NodePath("%s/MapUILayer" % GameController.get_root().get_path())
	return get_node(path) as CanvasLayer if has_node(path) else null
