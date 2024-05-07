extends Control

signal unit_selected

const _PHASE_DISPLAY_PATH: String = "res://maps/phase_display."
const _PHASE_DISPLAY = preload(_PHASE_DISPLAY_PATH + "gd")

@export var map_node: PackedScene

var selecting: bool = false  # Whether a unit is currently selected.
var map := Map.new()

var _phase_display: _PHASE_DISPLAY


func receive_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		AudioPlayer.clear_sound_effects()
		_phase_display.queue_free()


func set_scaling(new_scaling: int) -> void:
	var new_scale := Vector2(new_scaling, new_scaling)
	scale = new_scale
	MapController.map.scale = new_scale
	get_ui().scale = new_scale


func create_main_map_menu() -> void:
	## Creates map menu.
	const MAP_MENU_PATH: String = "res://ui/map_ui/map_menus/main_map_menu/main_map_menu.tscn"
	var menu := preload(MAP_MENU_PATH).instantiate() as MapMenu
	menu.offset = (CursorController.screen_position + Vector2i(16, 0))
	get_ui().add_child(menu)
	GameController.add_to_input_stack(menu)
	CursorController.disable()


func get_ui() -> CanvasLayer:
	var path := NodePath("%s/MapUILayer" % GameController.get_root().get_path())
	return get_node(path) as CanvasLayer if has_node(path) else CanvasLayer.new()


func get_map_camera() -> MapCamera:
	var path: String = NodePath("%s/MapCamera" % map.get_path())
	return (get_node(path) as MapCamera) if has_node(path) else MapCamera.new()


func get_dialogue() -> Dialogue:
	return get_ui().get_node("Dialogue") as Dialogue


func display_turn_change(faction: Faction) -> void:
	GameController.add_to_input_stack(self)
	const PHASE_DISPLAY_SCENE: PackedScene = preload(_PHASE_DISPLAY_PATH + "tscn")
	_phase_display = PHASE_DISPLAY_SCENE.instantiate() as _PHASE_DISPLAY
	get_ui().add_child(_phase_display)
	_phase_display.play(faction)
	await _phase_display.tree_exited
	GameController.remove_from_input_stack()
