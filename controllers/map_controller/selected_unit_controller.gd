## [Node] that handles selecting a tile for a [Unit] to act on.
class_name SelectedUnitController
extends Control

var _current_animation: Unit.Animations = Unit.Animations.IDLE
var _unit: Unit
var _ghost_unit: GhostUnit


func _init(connected_unit: Unit) -> void:
	_unit = connected_unit
	name = "SelectedUnitController"
	_unit.set_animation(Unit.Animations.MOVING_DOWN)
	_unit.selected = true
	_unit.update_path(CursorController.map_position)
	_unit.update_displayed_tiles()
	_unit.tree_exited.connect(_on_unit_death)
	_unit.display_movement_tiles()
	_ghost_unit = GhostUnit.new(_unit)
	_ghost_unit.position = CursorController.map_position
	MapController.map.get_child(0).add_child(_ghost_unit)
	CursorController.moved.connect(_on_cursor_moved)
	GameController.add_to_input_stack(self)
	_unit.arrived.connect(_update_ghost_unit)
	_update_ghost_unit()
	_unit.z_index = 1


func _receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_position_selected()
	elif event.is_action_pressed("ui_cancel"):
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		_canceled()


func _exit_tree() -> void:
	_ghost_unit.queue_free()
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	if hovered_unit and hovered_unit != _unit and not hovered_unit.dead:
		hovered_unit.display_movement_tiles()
	if is_instance_valid(_unit):
		_unit.deselect.call_deferred()
		_unit.z_index = 0


func _on_cursor_moved() -> void:
	if self == GameController.get_current_input_node():
		_unit.update_path(CursorController.map_position)
		_unit.show_path()
		_ghost_unit.position = _unit.get_path_last_pos()
		_update_ghost_unit()


func _update_ghost_unit() -> void:
	_ghost_unit.visible = _ghost_unit.position != _unit.position
	if _ghost_unit.visible == true:
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
		if _current_animation != next_animation:
			_ghost_unit.set_animation(next_animation)
			_current_animation = next_animation


func _position_selected() -> void:
	# Creates menu if cursor in _unit's tiles and is same faction as _unit.
	if _unit.faction.name == MapController.map.get_current_faction().name:
		if (
			CursorController.map_position in _unit._movement_tiles
			and UnitMenu.get_displayed_items(_unit).values().any(_is_true)
		):
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
			_create_unit_menu()
		elif (
			CursorController.get_hovered_unit()
			and CursorController.map_position in _unit.get_all_attack_tiles()
		):
			_attack_selection()
		else:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.INVALID)
	else:
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		queue_free()


func _create_unit_menu() -> void:
	var menu := UnitMenu.instantiate(
		CursorController.screen_position + Vector2i(16, 0), null, self, _unit
	)
	CursorController.disable()
	MapController.get_ui().add_child(menu)


func _canceled() -> void:
	queue_free()


func _on_unit_death() -> void:
	queue_free()


func _attack_selection() -> void:
	CursorController.disable()
	_unit.hide_movement_tiles()
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
	var info_display := CombatInfoDisplay.instantiate(
		_unit, CursorController.get_hovered_unit(), true
	)
	MapController.get_ui().add_child(info_display)
	_unit.display_current_attack_tiles()
	var completed: bool = await info_display.completed
	_unit.hide_current_attack_tiles()
	info_display.queue_free()
	if completed:
		GameController.add_to_input_stack(AttackController)
		await _unit.move()
		await AttackController.combat(_unit, CursorController.get_hovered_unit())
		_unit.wait()
		queue_free()
	else:
		_unit.display_movement_tiles()
	CursorController.enable()


func _is_true(value: bool) -> bool:
	return value
