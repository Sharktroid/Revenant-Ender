@abstract
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
var _old_map_pos: Vector2i


func _init(
	connected_unit: Unit,
	min_range: int,
	max_range: float,
	condition: Callable,
	icon: CursorController.Icons = CursorController.Icons.NONE,
	selection_sound_effect: AudioStream = AudioPlayer.SoundEffects.MENU_SELECT
) -> void:
	_old_map_pos = CursorController.map_position
	_unit = connected_unit
	_minimum_range = min_range
	_maximum_range = max_range
	_condition = condition
	_icon = icon
	_select_sound_effect = selection_sound_effect
	CursorController.enable()
	_unit.hide_movement_tiles()
	_unit.remove_path()
	_selecting_position = _unit.get_unit_path()[-1]


func _process(_delta: float) -> void:
	if _can_select() != _showing_icon:
		CursorController.set_icon(_icon if _can_select() else CursorController.Icons.NONE)
		_showing_icon = _can_select()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if _can_select():
			AudioPlayer.play_sound_effect(_select_sound_effect)
			_position_selected()
		else:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.INVALID)
	elif event.is_action_pressed("back"):
		_canceled()
	get_tree().root.set_input_as_handled()


func _exit_tree() -> void:
	CursorController.set_icon(CursorController.Icons.NONE)
	CursorController.map_position = _old_map_pos


func _position_selected() -> void:
	queue_free()


@abstract func _can_select() -> bool


@abstract func _within_range() -> bool


func _canceled() -> void:
	CursorController.disable()
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
	_unit.display_movement_tiles()
	_unit.show_path()
	queue_free()
