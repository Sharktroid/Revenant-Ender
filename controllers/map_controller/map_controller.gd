extends Control

signal unit_selected

@export var map_node: PackedScene

var selecting: bool = false # Whether a unit is currently selected.
var map: Map

func _has_point(_point: Vector2) -> bool:
	return true


func set_scaling(new_scaling: int) -> void:
	var new_scale := Vector2(new_scaling, new_scaling)
	scale = new_scale
	MapController.map.scale = new_scale
	$"UILayer".scale = new_scale


func create_main_map_menu() -> void:
	## Creates map menu.
	var menu: MapMenu = load("uid://dqvj6gc7ykdcp").instantiate()
	MapController.get_ui().add_child(menu)
	MapController.get_cursor().disable()


func get_ui() -> CanvasLayer:
	return GameController.get_root().get_node("Map UI Layer")


func get_cursor() -> Cursor:
	return get_ui().get_node("Cursor")


func get_map_camera() -> MapCamera:
	return map.get_node("Map Camera")


func _on_banner_timer_timeout() -> void:
	$"UI Layer/Turn Banner".texture = null
	MapController.map.start_turn()


func _create_unit_menu() -> void:
	## Creates unit menu.
	var menu: MapMenu = load("uid://i3a0mes5l4au").instantiate()
	menu.connected_unit = MapController.get_cursor().get_hovered_unit()
	$"UI Layer".add_child(menu)
	MapController.get_cursor().disable()
