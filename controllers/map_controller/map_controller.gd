extends Control

signal unit_selected

@export var map_node: PackedScene

var selecting: bool = false # Whether a unit is currently selected.
var map := Map.new()

func _has_point(_point: Vector2) -> bool:
	return true


func set_scaling(new_scaling: int) -> void:
	var new_scale := Vector2(new_scaling, new_scaling)
	scale = new_scale
	MapController.map.scale = new_scale
	$"UILayer".scale = new_scale


func create_main_map_menu() -> void:
	## Creates map menu.
	var menu: MapMenu = \
			preload("res://ui/map_ui/map_menus/main_map_menu/main_map_menu.tscn").instantiate()
	menu.offset = MapController.get_cursor().get_rel_pos() \
			+ MapController.get_map_camera().get_map_offset() + Vector2i(16, 0)
	MapController.get_ui().add_child(menu)
	MapController.get_cursor().disable()


func get_ui() -> CanvasLayer:
	if GameController.get_root() and GameController.get_root().has_node("Map UI Layer"):
		return GameController.get_root().get_node("Map UI Layer")
	else:
		return CanvasLayer.new()


func get_cursor() -> Cursor:
	if get_ui().has_node("Cursor"):
		return get_ui().get_node("Cursor")
	else:
		return Cursor.new()


func get_map_camera() -> MapCamera:
	return (map.get_node("Map Camera") as MapCamera)


func get_units() -> Array[Unit]:
	var units: Array[Unit] = []
	for node in get_tree().get_nodes_in_group("unit"):
		units.append(node)
	return units


func get_dialogue() -> Dialogue:
	return get_ui().get_node("Dialogue")


func _on_banner_timer_timeout() -> void:
	$"UI Layer/Turn Banner".texture = null
	MapController.map.start_turn()
