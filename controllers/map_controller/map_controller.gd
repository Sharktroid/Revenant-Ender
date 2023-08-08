extends Control
class_name MapController

signal unit_selected

@export var map_node: PackedScene

var ghost_unit: Unit # Unit used for echo effect when a unit is selected.
var selecting: bool = false # Whether a unit is currently selected.


func _enter_tree() -> void:
	GenVars.map_controller = self
	var map: Map = map_node.instantiate()
	$"Map Camera".add_child(map)


func _ready() -> void:
	grab_focus()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ranges"):
		if GenVars.cursor.get_hovered_unit():
			GenVars.map.toggle_outline_unit(GenVars.cursor.get_hovered_unit())
		else:
			GenVars.map.toggle_full_outline()

	elif event.is_action_pressed("ui_select"):
		_on_cursor_select()

	elif event.is_action_pressed("status"):
		var status_menu: Control = load("uid://dfm25r0ju5214").instantiate()
		$"UI Layer".add_child(status_menu)


func _process(_delta: float) -> void:
	if is_instance_valid(ghost_unit) and is_instance_valid(GenVars.cursor.get_hovered_unit()):
		var parent: Unit = GenVars.cursor.get_hovered_unit()
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
				distance = GenVars.cursor.get_true_pos() as Vector2 - ghost_unit.position
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


func _has_point(_point: Vector2) -> bool:
	return true


func set_scaling(new_scaling: int) -> void:
	var new_scale := Vector2(new_scaling, new_scaling)
	scale = new_scale
	GenVars.map.scale = new_scale
	$"UILayer".scale = new_scale


func _on_banner_timer_timeout() -> void:
	$"UI Layer/Turn Banner".texture = null
	GenVars.map.start_turn()


func _create_main_map_menu() -> void:
	## Creates map menu.
	var menu: MapMenu = load("uid://dqvj6gc7ykdcp").instantiate()
	$"UI Layer".add_child(menu)
	GenVars.cursor.disable()


func _create_unit_menu() -> void:
	## Creates unit menu.
	var menu: MapMenu = load("uid://i3a0mes5l4au").instantiate()
	menu.connected_unit = GenVars.cursor.get_hovered_unit()
	$"UI Layer".add_child(menu)
	(GenVars.cursor as Cursor).disable()


func _on_cursor_select() -> void:
	var hovered_unit: Unit = GenVars.cursor.get_hovered_unit()
	if hovered_unit and hovered_unit.selectable == true:
		var controller = SelectedUnitController.new(hovered_unit)
		add_child(controller)
		selecting = true

	else:
		_create_main_map_menu()


func _on_cursor_moved() -> void:
	var hovered_unit: Unit = GenVars.cursor.get_hovered_unit()
	if is_instance_valid(hovered_unit) and hovered_unit.selected and not selecting:
		hovered_unit.update_path(GenVars.cursor.get_true_pos())
		hovered_unit.show_path()
