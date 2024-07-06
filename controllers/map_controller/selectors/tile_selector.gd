class_name TileSelector
extends Selector

signal selected(position: Vector2)


func _init(
	connected_unit: Unit,
	min_range: int,
	max_range: float,
	condition: Callable,
	icon: CursorController.Icons = CursorController.Icons.NONE,
	selection_sound_effect: AudioStream = AudioPlayer.SoundEffects.MENU_SELECT
) -> void:
	name = "TileSelector"
	super(connected_unit, min_range, max_range, condition, icon, selection_sound_effect)


func _position_selected() -> void:
	selected.emit(CursorController.map_position)
	super()


func _can_select() -> bool:
	return _within_range() and _condition.call(CursorController.map_position)


func _within_range() -> bool:
	var dist: float = Utilities.get_tile_distance(
		CursorController.map_position, _selecting_position
	)
	return dist >= _minimum_range and dist <= _maximum_range


func _canceled() -> void:
	selected.emit(Vector2.INF)
	super()
