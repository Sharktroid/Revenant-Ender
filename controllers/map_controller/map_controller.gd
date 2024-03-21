extends Control

signal unit_selected

const _PHASE_DISPLAY_PATH: String = "res://maps/phase_display."
const _PHASE_DISPLAY = preload(_PHASE_DISPLAY_PATH + "gd")

@export var map_node: PackedScene

var selecting: bool = false # Whether a unit is currently selected.
var map := Map.new()

var _phase_diplay: _PHASE_DISPLAY

func receive_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		AudioPlayer.clear_sound_effects()
		_phase_diplay.queue_free()


func set_scaling(new_scaling: int) -> void:
	var new_scale := Vector2(new_scaling, new_scaling)
	scale = new_scale
	MapController.map.scale = new_scale
	get_ui().scale = new_scale


func create_main_map_menu() -> void:
	## Creates map menu.
	var menu := preload("res://ui/map_ui/map_menus/main_map_menu/" +
			"main_map_menu.tscn").instantiate() as MapMenu
	menu.offset = (CursorController.get_screen_position() + Vector2i(16, 0))
	MapController.get_ui().add_child(menu)
	GameController.add_to_input_stack(menu)
	CursorController.disable()


func get_ui() -> CanvasLayer:
	if GameController.get_root() and GameController.get_root().has_node("Map UI Layer"):
		return GameController.get_root().get_node("Map UI Layer") as CanvasLayer
	else:
		return CanvasLayer.new()


func get_map_camera() -> MapCamera:
	const PATH: String = "Map Camera"
	if map.has_node(PATH):
		return (map.get_node(PATH) as MapCamera)
	else:
		return MapCamera.new()


func get_units() -> Array[Unit]:
	var units: Array[Unit] = []
	if is_inside_tree():
		for node: Node in get_tree().get_nodes_in_group("unit"):
			units.append(node)
	return units


func get_dialogue() -> Dialogue:
	return get_ui().get_node("Dialogue") as Dialogue


func display_turn_change(faction: Faction) -> void:
	GameController.add_to_input_stack(self)
	const PHASE_DISPLAY_SCENE: PackedScene = preload(_PHASE_DISPLAY_PATH + "tscn")
	_phase_diplay = PHASE_DISPLAY_SCENE.instantiate() as _PHASE_DISPLAY
	get_ui().add_child(_phase_diplay)
	_phase_diplay.play(faction)
	await _phase_diplay.tree_exited
	GameController.remove_from_input_stack()

