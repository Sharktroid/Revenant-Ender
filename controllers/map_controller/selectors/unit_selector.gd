## A [Selector] that allows selection of a [Unit].
class_name UnitSelector
extends Selector

## Emitted when a unit is selected. Provides said unit as an argument.
signal selected(unit: Unit)


func _init(
	connected_unit: Unit,
	min_range: int,
	max_range: float,
	condition: Callable,
	icon: CursorController.Icons = CursorController.Icons.NONE,
	selection_sound_effect: AudioStream = AudioPlayer.SoundEffects.MENU_SELECT
) -> void:
	name = "UnitSelector"
	super(connected_unit, min_range, max_range, condition, icon, selection_sound_effect)


func _position_selected() -> void:
	selected.emit(CursorController.get_hovered_unit())
	super()


func _can_select() -> bool:
	return _within_range() and _condition.call(CursorController.get_hovered_unit())


func _within_range() -> bool:
	if CursorController.get_hovered_unit():
		var dist: float = Utilities.get_tile_distance(
			CursorController.get_hovered_unit().position, _selecting_position
		)
		return dist >= _minimum_range and dist <= _maximum_range
	return false


func _canceled() -> void:
	selected.emit(null)
	super()
