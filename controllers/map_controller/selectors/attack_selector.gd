class_name AttackSelector
extends UnitSelector

const _INFO_DISPLAY_PATH: String = "res://ui/combat_info_display/combat_info_display."
const _INFO_DISPLAY = preload(_INFO_DISPLAY_PATH + "gd")

var _info_display: _INFO_DISPLAY


func _init(
	connected_unit: Unit,
	min_range: int,
	max_range: float,
	condition: Callable,
	icon: CursorController.Icons = CursorController.Icons.ATTACK,
	selection_sound_effect: AudioStream = AudioPlayer.MENU_SELECT
) -> void:
	CursorController.moved.connect(_cursor_moved)
	super(connected_unit, min_range, max_range, condition, icon, selection_sound_effect)


func _ready() -> void:
	const INFO_DISPLAY_SCENE: PackedScene = preload(_INFO_DISPLAY_PATH + "tscn")
	_info_display = INFO_DISPLAY_SCENE.instantiate() as _INFO_DISPLAY
	_info_display.top_unit = unit
	MapController.get_ui().add_child(_info_display)
	_update_bottom_unit()



func close() -> void:
	_info_display.queue_free()
	super()


func _cursor_moved() -> void:
	_update_bottom_unit()


func _position_selected() -> void:
	if _can_select():
		CursorController.disable()
		_info_display.focus()
		var proceed: bool = await _info_display.completed
		CursorController.enable()
		if proceed:
			_info_display.queue_free()
			selected.emit(CursorController.get_hovered_unit())
			close()


func _update_bottom_unit() -> void:
	_info_display.visible = _within_range() and _condition.call(CursorController.get_hovered_unit())
	if _info_display.visible:
		var bottom_unit: Unit = CursorController.get_hovered_unit()
		_info_display.distance = roundi(
			Utilities.get_tile_distance(_selecting_position, bottom_unit.position)
		)
		_info_display.bottom_unit = bottom_unit
		if CursorController.screen_position.x < (Utilities.get_screen_size().x as float / 2):
			_info_display.position.x = Utilities.get_screen_size().x - _info_display.size.x
		else:
			_info_display.position.x = 0
