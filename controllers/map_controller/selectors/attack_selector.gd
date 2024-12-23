## [UnitSelector] that utilizes a [CombatInfoDisplay].
class_name AttackSelector
extends UnitSelector

var _info_display: CombatInfoDisplay


func _init(
	connected_unit: Unit,
	min_range: int,
	max_range: float,
	condition: Callable,
	icon: CursorController.Icons = CursorController.Icons.ATTACK,
	selection_sound_effect: AudioStream = AudioPlayer.SoundEffects.MENU_SELECT
) -> void:
	CursorController.moved.connect(func() -> void: _update_bottom_unit())
	super(connected_unit, min_range, max_range, condition, icon, selection_sound_effect)
	name = "AttackSelector"


func _ready() -> void:
	_info_display = CombatInfoDisplay.instantiate(_unit) as CombatInfoDisplay
	MapController.get_ui().add_child(_info_display)
	_update_bottom_unit()
	_unit.display_current_attack_tiles(true)


func _exit_tree() -> void:
	_info_display.queue_free()
	super()


func _position_selected() -> void:
	if _can_select():
		CursorController.disable()
		_info_display.focus()
		var proceed: bool = await _info_display.completed
		CursorController.enable()
		if proceed:
			selected.emit(CursorController.get_hovered_unit())
			GameController.add_to_input_stack(AttackController)
			CursorController.disable()
			queue_free()


func _update_bottom_unit() -> void:
	_info_display.visible = _within_range() and _condition.call(CursorController.get_hovered_unit())
	if _info_display.visible:
		_info_display.bottom_unit = CursorController.get_hovered_unit()
