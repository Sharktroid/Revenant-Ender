class_name SelectedUnitController
extends Node

var unit: Unit
var _ghost_unit: Unit

func _init(connected_unit: Unit) -> void:
	unit = connected_unit


func _ready() -> void:
	unit.map_animation = Unit.animations.MOVING_DOWN
	unit.selected = true
	unit.update_path(GenVars.get_cursor().get_true_pos())
	unit.refresh_tiles()
	(GenVars.get_cursor() as Cursor).connect_to(self)


func _on_cursor_moved() -> void:
	if unit.selected:
		unit.update_path(GenVars.get_cursor().get_true_pos())
		unit.show_path()


func _create_unit_menu() -> void:
	## Creates unit menu.
	var menu: MapMenu = preload("res://Menus/Map Menus/unit_menu.tscn").instantiate()
	menu.connected_unit = unit
	menu.position = GenVars.get_cursor().get_rel_pos() + Vector2i(16, -8)
	GenVars.get_level_controller().get_node("UILayer").add_child(menu)
	GenVars.get_cursor().set_active(false)


func _on_cursor_select() -> void:
	# Creates menu if cursor in unit's tiles and is same faction as unit.
	var true_cursor_pos: Vector2i = GenVars.get_cursor().get_true_pos()
	var all_tiles: Array = unit.all_attack_tiles + unit.raw_movement_tiles
	var unit_pos: Vector2i = unit.position
	if unit.get_faction().name == GenVars.get_map().get_current_faction().name \
			and (true_cursor_pos in all_tiles or unit_pos == true_cursor_pos):
		_create_unit_menu()
		(GenVars.get_cursor() as Cursor).disconnect_from(self)



func _on_cursor_cancel() -> void:
	_deselect_unit()


func _deselect_unit() -> void:
	## Deselects the currently selected unit.
#	_ghost_unit.queue_free()
#	await _ghost_unit.tree_exited
	await unit.deselect()
	var _cursor_area: Area2D = GenVars.get_cursor().get_area()
	# Searches for another unit below the cursor.
#	if not(_is_cursor_over_hovered_unit()):
#		for unit in get_tree().get_nodes_in_group("units"):
#			if Vector2i(unit.position) == GenVars.get_cursor().get_true_pos():
#				hovered_unit = unit
#				hovered_unit.get_node("Area2D").emit_signal("area_entered", cursor_area)
#				break
	queue_free()
