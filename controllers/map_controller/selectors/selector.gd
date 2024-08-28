## Abstract class for handling selecting with the cursor.
class_name Selector
extends Control

var _unit: Unit
var _condition: Callable
var _minimum_range: int
var _maximum_range: float
var _icon: CursorController.Icons
var _selecting_position: Vector2i
var _select_sound_effect: AudioStream
var _showing_icon: bool


func _init(
	connected_unit: Unit,
	min_range: int,
	max_range: float,
	condition: Callable,
	icon: CursorController.Icons = CursorController.Icons.NONE,
	selection_sound_effect: AudioStream = AudioPlayer.SoundEffects.MENU_SELECT
) -> void:
	_unit = connected_unit
	_minimum_range = min_range
	_maximum_range = max_range
	_condition = condition
	_icon = icon
	_select_sound_effect = selection_sound_effect
	CursorController.enable()
	_unit.hide_movement_tiles()
	_unit.remove_path()
	GameController.add_to_input_stack(self)
	_selecting_position = _unit.get_unit_path()[-1]


func _process(_delta: float) -> void:
	var should_show_icon: bool = _can_select()
	if should_show_icon != _showing_icon:
		CursorController.set_icon(_icon if should_show_icon else CursorController.Icons.NONE)
		_showing_icon = should_show_icon


func _receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _can_select():
			AudioPlayer.play_sound_effect(_select_sound_effect)
			_position_selected()
		else:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.INVALID)
	elif event.is_action_pressed("ui_cancel"):
		_canceled()


func _exit_tree() -> void:
	CursorController.set_icon(CursorController.Icons.NONE)


func _close() -> void:
	queue_free()


func _position_selected() -> void:
	_close()


func _can_select() -> bool:
	return false  # Abstract


func _within_range() -> bool:
	var dist: float = Utilities.get_tile_distance(
		CursorController.get_hovered_unit().position, _selecting_position
	)
	return dist >= _minimum_range and dist <= _maximum_range


func _canceled() -> void:
	CursorController.disable()
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
	_unit.display_movement_tiles()
	_unit.show_path()
	_close()
