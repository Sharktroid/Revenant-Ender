class_name SelectedUnitController
extends Control

var _unit: Unit
var _ghost_unit: GhostUnit
var _menu_node: PackedScene = load("res://ui/map_ui/map_menus/unit_menu/unit_menu.tscn")
var current_animation: Unit.animations = Unit.animations.IDLE

func _init(connected_unit: Unit) -> void:
	_unit = connected_unit
	name = "Selected Unit Controller"
	_unit.set_animation(Unit.animations.MOVING_DOWN)
	_unit.selected = true
	_unit.update_path(CursorController.get_true_pos())
	_unit.refresh_tiles()
	_unit.tree_exited.connect(_on_unit_death)
	_ghost_unit = GhostUnit.new(_unit)
	MapController.map.get_child(0).add_child(_ghost_unit)
	CursorController.moved.connect(_on_cursor_moved)


func _enter_tree() -> void:
	set_focus_mode(Control.FOCUS_ALL)
	MapController.set_focus_mode(Control.FOCUS_NONE)
	grab_focus()


func _process(_delta: float) -> void:
	_ghost_unit.position = _unit.get_path_last_pos()
	if _ghost_unit.position == _unit.position:
		_ghost_unit.visible = false
	else:
		_ghost_unit.visible = true
		var distance = Vector2i()
		if len(_unit.get_unit_path()) >= 2:
			distance = _unit.get_unit_path()[-1] - _unit.get_unit_path()[-2]
		var next_animation: Unit.animations
		match distance:
			Vector2i(16, 0): next_animation = Unit.animations.MOVING_RIGHT
			Vector2i(-16, 0): next_animation = Unit.animations.MOVING_LEFT
			Vector2i(0, -16): next_animation = Unit.animations.MOVING_UP
			_: next_animation = Unit.animations.MOVING_DOWN
		if current_animation != next_animation:
			_ghost_unit.set_animation(next_animation)
			current_animation = next_animation


func _has_point(_point: Vector2) -> bool:
	return true


func _gui_input(event: InputEvent) -> void:
	if CursorController.is_active():
		if event.is_action_pressed("ui_accept"):
			_position_selected()
			accept_event()
		elif event.is_action_pressed("ui_cancel"):
			_canceled()


func close() -> void:
	## Deselects the currently selected _unit.
	_unit.deselect()
	queue_free()
	_ghost_unit.queue_free()
	MapController.selecting = false
	MapController.map.set_focus_mode(Control.FOCUS_ALL)
	MapController.map.grab_focus()
	if CursorController.get_hovered_unit():
		CursorController.get_hovered_unit().display_movement_tiles()


func _on_cursor_moved() -> void:
	if has_focus():
		_unit.update_path(CursorController.get_true_pos())
		_unit.show_path()


func _position_selected() -> void:
	# Creates menu if cursor in _unit's tiles and is same faction as _unit.
	if _unit.get_faction().name == MapController.map.get_current_faction().name:
		_create_unit_menu()
	else:
		close()


func _create_unit_menu() -> void:
	## Creates _unit menu.
	var menu: MapMenu = _menu_node.instantiate()
	menu.connected_unit = _unit
	menu.offset = CursorController.get_rel_pos() \
			+ MapController.get_map_camera().get_map_offset() + Vector2i(16, -8)
	menu.caller = self
	set_focus_mode(Control.FOCUS_NONE)
	CursorController.disable()
	MapController.get_ui().add_child(menu)


func _canceled() -> void:
	close()


func _on_unit_death() -> void:
	close()
