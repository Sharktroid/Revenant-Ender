## Autoload that manages and interfaces for the current [Map].
extends Control

## The currently active [Map].
var map := Map.new()


## Returns the [CanvasLayer] containing the Map's UI.
func get_ui() -> CanvasLayer:
	var path := NodePath("%s/MapUILayer" % GameController.get_root().get_path())
	return get_node(path) as CanvasLayer if has_node(path) else null


## Returns the [Map]'s [MapCamera].
func get_map_camera() -> MapCamera:
	var path: String = NodePath("%s/MapCamera" % map.get_path())
	return (get_node(path) as MapCamera) if has_node(path) else MapCamera.new()
