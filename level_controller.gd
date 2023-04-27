extends Node2D
class_name LevelController

signal unit_selected

@export var map_node: PackedScene

#var default_unit = preload("res://Unit Classes/unit_base.tscn").instantiate()
var ghost_unit: Unit # Unit used for echo effect when a unit is selected.
var hovered_unit = preload("res://Unit Classes/unit_base.tscn").instantiate() # Unit that is under the cursor.
var selecting: bool = false # Unit that is selecting another unit for an action.


func _enter_tree() -> void:
	var map = map_node.instantiate()
#	hovered_unit = map.get_node("Base Layer/Units").get_child(0).duplicate() # prevents errors.
	$"Map Camera".add_child(map)
#	$SubViewportContainer/SubViewport.add_child(map)
	# Setting general variables.
#	GenVars.set_map($"Test Map B")
#	GenVars.set_level_controller(self)
#	GenVars.set_cursor($UILayer/Cursor)


#func _ready():
#	set_scaling(3)


#func _draw():
#	var screen_offset = GenVars.get_screen_size() % 16 / 2
#	draw_rect(Rect2(0, 0, GenVars.get_screen_size().x, screen_offset.y), Color.HOT_PINK)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var true_cursor_pos = GenVars.get_cursor().get_true_pos()
		# When a unit is selecting another unit.
		if selecting:
			var selected_unit: Unit = get_node("UILayer/Unit Menu").connected_unit
			if true_cursor_pos in selected_unit.get_current_attack_tiles(selected_unit.get_unit_path()[-1]) \
					and _is_cursor_over_hovered_unit():
				emit_signal("unit_selected", hovered_unit)

		# When a unit has already been selected.
		elif hovered_unit.selected:
			var all_tiles = hovered_unit.all_attack_tiles + hovered_unit.raw_movement_tiles
			# Creates menu if cursor in unit's tiles and is same faction as unit.
			var unit_pos: Vector2 = hovered_unit.position
			if hovered_unit.get_faction().name == GenVars.get_map().get_current_faction().name \
					and (true_cursor_pos in all_tiles or unit_pos == true_cursor_pos):
				_create_unit_menu()

		# When hovering over a unit.
		elif _is_cursor_over_hovered_unit() and hovered_unit.selectable == true:
			# Immediatly displays menu as unit has no need to move.
#			if hovered_unit.current_movement == 0:
#				_create_unit_menu()
#			else:
				# Selects unit.
			hovered_unit.selected = true
			hovered_unit.update_path(GenVars.get_cursor().get_true_pos())
			hovered_unit.refresh_tiles()
			ghost_unit = hovered_unit.duplicate()
			ghost_unit.make_ghost()
			hovered_unit.get_parent().add_child(ghost_unit)
			hovered_unit.map_animation = Unit.animations.MOVING_DOWN

		else:
			_create_main_map_menu()

	elif event.is_action_pressed("ui_cancel"):
		if selecting:
			# Cancels the metaunit selection.
			emit_signal("unit_selected", null)
		elif hovered_unit.selected == true:
			await _deselect_unit()

	elif event.is_action_pressed("ranges"):
		if _is_cursor_over_hovered_unit():
			GenVars.get_map().toggle_outline_unit(hovered_unit)
		else:
			GenVars.get_map().toggle_full_outline()

#	elif event.is_action_pressed("ui_up"):
#		$"Map Camera".destination.y -= 16
#	elif event.is_action_pressed("ui_down"):
#		$"Map Camera".destination.y += 16
#	elif event.is_action_pressed("ui_left"):
#		$"Map Camera".destination.x -= 16
#	elif event.is_action_pressed("ui_right"):
#		$"Map Camera".destination.x += 16

#	elif event.is_action_pressed("debug"):
#		$UILayer/Temp.queue_redraw()
#		var bottom = get_viewport().size.y/GenVars.scaling
#		$UILayer/Top.polygon = [Vector2(0, 0), Vector2(GenVars.get_map().get_size().x, 0), Vector2(GenVars.get_map().get_size().x, 16), Vector2(0, 16)]
#		$UILayer/Bottom.polygon = [Vector2(0, bottom - 16), Vector2(GenVars.get_map().get_size().x, bottom - 16), Vector2(GenVars.get_map().get_size().x, bottom), Vector2(0, bottom)]
#		draw_line(Vector2(0, 16), Vector2(GenVars.get_map().get_size().x, 16), Color.BLUE, 2.0)
#		draw_line(Vector2(0, bottom), Vector2(GenVars.get_map().get_size().x, bottom), Color.BLUE, 2.0)


func _process(_delta: float) -> void:
#	if selected_unit:
	if is_instance_valid(ghost_unit) and is_instance_valid(hovered_unit):
		var parent: Unit = hovered_unit
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
			var angle = distance.angle()/PI
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
	# Turns on/off input of the game controller and cursor.
	# process: value the input will be set too.
	set_process_input(process)
	GenVars.get_cursor().set_process_input(process)


func set_scaling(new_scaling: int) -> void:
#	print_debug(new_scaling)
	var new_scale := Vector2(new_scaling, new_scaling)
#	global_scale
	scale = new_scale
	GenVars.get_map().scale = new_scale
	$"UILayer".scale = new_scale


func _is_cursor_over_hovered_unit() -> bool:
	if is_instance_valid(hovered_unit):
		return hovered_unit.get_node("Area2D").overlaps_area(GenVars.get_cursor_area())
	else:
		return false


func _on_banner_timer_timeout() -> void:
	$"UILayer/Turn Banner".texture = null
	GenVars.get_map().start_turn()


func _deselect_unit() -> void:
	# Deselects the currently selected unit.
	ghost_unit.queue_free()
	await ghost_unit.tree_exited
	await hovered_unit.deselect()
	var cursor_area = GenVars.get_cursor_area()
	# Searches for another unit below the cursor.
	if not(_is_cursor_over_hovered_unit()):
		for unit in get_tree().get_nodes_in_group("units"):
			if Vector2i(unit.position) == GenVars.get_cursor().get_true_pos():
				hovered_unit = unit
				hovered_unit.get_node("Area2D").emit_signal("area_entered", cursor_area)
				break


func _create_main_map_menu() -> void:
	# Creates map menu.
	var menu: MapMenu = preload("res://Menus/Map Menus/main_map_menu.tscn").instantiate()
	menu.position = GenVars.get_cursor().get_rel_pos() + Vector2i(16, -8)
	$UILayer.add_child(menu)
	handle_input(false)


func _create_unit_menu() -> void:
	# Creates unit menu.
	var menu: MapMenu = preload("res://Menus/Map Menus/unit_menu.tscn").instantiate()
	menu.connected_unit = hovered_unit
	menu.position = GenVars.get_cursor().get_rel_pos() + Vector2i(16, -8)
	$UILayer.add_child(menu)
	handle_input(false)


func _on_cursor_moved() -> void:
	if is_instance_valid(hovered_unit) and hovered_unit.selected and not selecting:
		hovered_unit.update_path(GenVars.get_cursor().get_true_pos())
		hovered_unit.show_path()
