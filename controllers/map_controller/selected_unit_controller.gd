class_name SelectedUnitController
extends Control

var current_animation: Unit.Animations = Unit.Animations.IDLE
var _unit: Unit
var _ghost_unit: GhostUnit


func _init(connected_unit: Unit) -> void:
	_unit = connected_unit
	name = "Selected UnitController"
	_unit.set_animation(Unit.Animations.MOVING_DOWN)
	_unit.selected = true
	_unit.update_path(CursorController.map_position)
	_unit.update_displayed_tiles()
	_unit.tree_exited.connect(_on_unit_death)
	_ghost_unit = GhostUnit.new(_unit)
	MapController.map.get_child(0).add_child(_ghost_unit)
	CursorController.moved.connect(_on_cursor_moved)
	GameController.add_to_input_stack(self)


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_position_selected()
		accept_event()
	elif event.is_action_pressed("ui_cancel"):
		AudioPlayer.play_sound_effect(AudioPlayer.DESELECT)
		_canceled()


func close() -> void:
	## Deselects the currently selected _unit.
	queue_free()
	_ghost_unit.queue_free()
	MapController.selecting = false
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	if hovered_unit and hovered_unit != _unit and not hovered_unit.dead:
		hovered_unit.display_movement_tiles()
	_unit.deselect.call_deferred()


func _on_cursor_moved() -> void:
	if self == GameController.get_current_input_node():
		_unit.update_path(CursorController.map_position)
		_unit.show_path()
		_ghost_unit.position = _unit.get_path_last_pos()
		if _ghost_unit.position == _unit.position:
			_ghost_unit.visible = false
		else:
			_ghost_unit.visible = true
			var distance := Vector2i()
			if _unit.get_unit_path().size() >= 2:
				distance = _unit.get_unit_path()[-1] - _unit.get_unit_path()[-2]
			var next_animation: Unit.Animations
			match distance:
				Vector2i(16, 0):
					next_animation = Unit.Animations.MOVING_RIGHT
				Vector2i(-16, 0):
					next_animation = Unit.Animations.MOVING_LEFT
				Vector2i(0, -16):
					next_animation = Unit.Animations.MOVING_UP
				_:
					next_animation = Unit.Animations.MOVING_DOWN
			if current_animation != next_animation:
				_ghost_unit.set_animation(next_animation)
				current_animation = next_animation


func _position_selected() -> void:
	# Creates menu if cursor in _unit's tiles and is same faction as _unit.
	if _unit.faction.name == MapController.map.get_current_faction().name:
		AudioPlayer.play_sound_effect(AudioPlayer.MENU_SELECT)
		_create_unit_menu()
	else:
		AudioPlayer.play_sound_effect(AudioPlayer.DESELECT)
		close()


func _create_unit_menu() -> void:
	## Creates _unit menu.
	const MenuScript = preload("res://ui/map_ui/map_menus/unit_menu/unit_menu.gd")
	var menu_node := load("res://ui/map_ui/map_menus/unit_menu/unit_menu.tscn") as PackedScene
	var menu := menu_node.instantiate() as MenuScript
	menu.connected_unit = _unit
	menu.offset = CursorController.screen_position + Vector2i(16, 0)
	menu.caller = self
	CursorController.disable()
	MapController.get_ui().add_child(menu)


func _canceled() -> void:
	close()


func _on_unit_death() -> void:
	close()
