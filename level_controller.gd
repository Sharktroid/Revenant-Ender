extends Node2D
class_name LevelController

signal unit_selected

@export var map_node: PackedScene

var ghost_unit: Unit # Unit used for echo effect when a unit is selected.
var selecting: bool = false # Unit that is selecting another unit for an action.


func _enter_tree() -> void:
	var map: Map = map_node.instantiate()
	$"Map Camera".add_child(map)
	GenVars.get_cursor().connect_to(self)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ranges"):
		if _is_cursor_over_hovered_unit():
			GenVars.get_map().toggle_outline_unit(GenVars.get_cursor().get_hovered_unit())
		else:
			GenVars.get_map().toggle_full_outline()

#	elif event.is_action_pressed("debug"):
#		$UILayer/Temp.queue_redraw()
#		var bottom = get_viewport().size.y/GenVars.scaling
#		$UILayer/Top.polygon = [Vector2(0, 0), Vector2(GenVars.get_map().get_size().x, 0), Vector2(GenVars.get_map().get_size().x, 16), Vector2(0, 16)]
#		$UILayer/Bottom.polygon = [Vector2(0, bottom - 16), Vector2(GenVars.get_map().get_size().x, bottom - 16), Vector2(GenVars.get_map().get_size().x, bottom), Vector2(0, bottom)]
#		draw_line(Vector2(0, 16), Vector2(GenVars.get_map().get_size().x, 16), Color.BLUE, 2.0)
#		draw_line(Vector2(0, bottom), Vector2(GenVars.get_map().get_size().x, bottom), Color.BLUE, 2.0)


func _process(_delta: float) -> void:
	if is_instance_valid(ghost_unit) and is_instance_valid(GenVars.get_cursor().get_hovered_unit()):
		var parent: Unit = GenVars.get_cursor().get_hovered_unit()
		ghost_unit.raw_movement_tiles = parent.raw_movement_tiles
		var coords: Vector2i = ghost_unit.position
		if not selecting:
			coords = Vector2i(-1, -1)
			for i in range(len(parent.get_unit_path()), 1, -1):
				var overlap: bool = false
				coords = parent.get_unit_path()[i - 1]
				for unit in get_tree().get_nodes_in_group("units"):
					if Vector2i(unit.position) == coords and not unit.is_ghost:
						overlap = true
						break
				if not overlap:
					break
		if coords == Vector2i(-1, -1):
			ghost_unit.visible = false
		else:
			ghost_unit.visible = true
			if not selecting:
				ghost_unit.position = coords as Vector2
			var distance: Vector2
			if selecting:
				# Ghost unit looks at cursor.
				distance = GenVars.get_cursor().get_true_pos() as Vector2 - ghost_unit.position
			else:
				# Ghost unit looks in the direction of the last tile in the unit's path.
				distance = coords - parent.get_unit_path()[parent.get_unit_path().find(coords) - 1]
			var angle: float = distance.angle()/PI
			# Converting the direction into proper animation.
			if not abs(distance.x) == abs(distance.y):
				if angle > 0.25 and angle < 0.75:
					ghost_unit.map_animation = Unit.animations.MOVING_DOWN
				elif angle < 0.25 and angle > -0.25:
					ghost_unit.map_animation = Unit.animations.MOVING_LEFT
				elif angle < -0.25 and angle > -0.75:
					ghost_unit.map_animation = Unit.animations.MOVING_UP
				elif angle < -0.75 or angle > 0.75:
					ghost_unit.map_animation = Unit.animations.MOVING_RIGHT


func handle_input(process: bool) -> void:
	## Turns on/off input of the game controller and cursor.
	## process: value the input will be set too.
	set_process_input(process)
	GenVars.get_cursor().set_process_input(process)


func set_scaling(new_scaling: int) -> void:
	var new_scale := Vector2(new_scaling, new_scaling)
	scale = new_scale
	GenVars.get_map().scale = new_scale
	$"UILayer".scale = new_scale


func _is_cursor_over_hovered_unit() -> bool:
	if is_instance_valid(GenVars.get_cursor().get_hovered_unit()):
		return GenVars.get_cursor().get_hovered_unit().get_node("Area2D").overlaps_area(GenVars.get_cursor().get_area())
	else:
		return false


func _on_banner_timer_timeout() -> void:
	$"UILayer/Turn Banner".texture = null
	GenVars.get_map().start_turn()


func _deselect_unit() -> void:
	## Deselects the currently selected unit.
	ghost_unit.queue_free()
	await ghost_unit.tree_exited
	await GenVars.get_cursor().get_hovered_unit().deselect()
	# Searches for another unit below the cursor.


func _create_main_map_menu() -> void:
	## Creates map menu.
	var menu: MapMenu = preload("res://Menus/Map Menus/main_map_menu.tscn").instantiate()
	menu.position = GenVars.get_cursor().get_rel_pos() + Vector2i(16, -8)
	$UILayer.add_child(menu)
	handle_input(false)


func _create_unit_menu() -> void:
	## Creates unit menu.
	var menu: MapMenu = preload("res://Menus/Map Menus/unit_menu.tscn").instantiate()
	menu.connected_unit = GenVars.get_cursor().get_hovered_unit()
	menu.position = GenVars.get_cursor().get_rel_pos() + Vector2i(16, -8)
	$UILayer.add_child(menu)
	handle_input(false)


func _on_cursor_select() -> void:
	if _is_cursor_over_hovered_unit() and GenVars.get_cursor().get_hovered_unit().selectable == true:
		var controller = SelectedUnitController.new(GenVars.get_cursor().get_hovered_unit())
		add_child(controller)
		GenVars.get_cursor().disconnect_from(self)

	else:
		_create_main_map_menu()


func _on_cursor_moved() -> void:
	if is_instance_valid(GenVars.get_cursor().get_hovered_unit()) and GenVars.get_cursor().get_hovered_unit().selected and not selecting:
		GenVars.get_cursor().get_hovered_unit().update_path(GenVars.get_cursor().get_true_pos())
		GenVars.get_cursor().get_hovered_unit().show_path()
