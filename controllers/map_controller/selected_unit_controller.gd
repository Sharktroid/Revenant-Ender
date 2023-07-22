class_name SelectedUnitController
extends Control

var _unit: Unit
var _ghost_unit: GhostUnit

func _init(connected_unit: Unit) -> void:
	_unit = connected_unit
	name = "Selected Unit Controller"


func _ready() -> void:
	_unit.map_animation = Unit.animations.MOVING_DOWN
	_unit.selected = true
	_unit.update_path(GenVars.get_cursor().get_true_pos())
	_unit.refresh_tiles()
	_unit.tree_exited.connect(_on_unit_death)
	_ghost_unit = GhostUnit.new(_unit)
	GenVars.get_map().add_child(_ghost_unit)
	(GenVars.get_cursor() as Cursor).moved.connect(_on_cursor_moved)
	set_focus_mode(Control.FOCUS_ALL)
	GenVars.get_level_controller().set_focus_mode(Control.FOCUS_NONE)
	grab_focus()


func _process(_delta: float) -> void:
	_ghost_unit.position = _unit.get_unit_path()[-1]
	if _ghost_unit.position == _unit.position:
		_ghost_unit.visible = false
	else:
		_ghost_unit.visible = true
		var distance = Vector2i()
		if len(_unit.get_unit_path()) >= 2:
			distance = _unit.get_unit_path()[-1] - _unit.get_unit_path()[-2]
		match distance:
			Vector2i(16, 0): _ghost_unit.set_animation(Unit.animations.MOVING_LEFT)
			Vector2i(-16, 0): _ghost_unit.set_animation(Unit.animations.MOVING_RIGHT)
			Vector2i(0, -16): _ghost_unit.set_animation(Unit.animations.MOVING_UP)
			_: _ghost_unit.set_animation(Unit.animations.MOVING_DOWN)


func _has_point(_point: Vector2) -> bool:
	return true


func _gui_input(event: InputEvent) -> void:
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
	GenVars.get_level_controller().selecting = false
	GenVars.get_level_controller().set_focus_mode(Control.FOCUS_ALL)
	GenVars.get_level_controller().grab_focus()


func _on_cursor_moved() -> void:
	if has_focus():
		_unit.update_path(GenVars.get_cursor().get_true_pos())
		_unit.show_path()


func _position_selected() -> void:
	# Creates menu if cursor in _unit's tiles and is same faction as _unit.
	var true_cursor_pos: Vector2i = GenVars.get_cursor().get_true_pos()
	var all_tiles: Array = _unit.all_attack_tiles + _unit.raw_movement_tiles
	var unit_pos: Vector2i = _unit.position
	if _unit.get_faction().name == GenVars.get_map().get_current_faction().name \
			and (true_cursor_pos in all_tiles or unit_pos == true_cursor_pos):
		_create_unit_menu()


func _create_unit_menu() -> void:
	## Creates _unit menu.
	var menu: MapMenu = load("uid://i3a0mes5l4au").instantiate()
	menu.connected_unit = _unit
	menu.position = GenVars.get_cursor().get_rel_pos() + Vector2i(16, -8)
	menu.caller = self
	GenVars.get_level_controller().get_node("UI Layer").add_child(menu)
	set_focus_mode(Control.FOCUS_NONE)
	GenVars.get_cursor().disable()


func _canceled() -> void:
	close()


func _on_unit_death() -> void:
	close()
