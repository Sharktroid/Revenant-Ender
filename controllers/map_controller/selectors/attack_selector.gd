class_name AttackSelector
extends UnitSelector


func _init(
	connected_unit: Unit,
	min_range: int,
	max_range: int,
	condition: Callable,
	icon: CursorController.Icons = CursorController.Icons.ATTACK,
	selection_sound_effect: AudioStream = AudioPlayer.MENU_SELECT
) -> void:
	super(connected_unit, min_range, max_range, condition, icon, selection_sound_effect)

func _position_selected() -> void:
	if _can_select():
		const INFO_DISPLAY_PATH: String = "res://ui/combat_info_display/combat_info_display."
		const InfoDisplay = preload(INFO_DISPLAY_PATH + "gd")
		const INFO_DISPLAY_SCENE: PackedScene = preload(INFO_DISPLAY_PATH + "tscn")
		var info_display := INFO_DISPLAY_SCENE.instantiate() as InfoDisplay
		if (
			CursorController.screen_position.x + MapController.get_map_camera().get_map_offset().x
			< (Utilities.get_screen_size().x as float / 2)
		):
			info_display.position.x = Utilities.get_screen_size().x - info_display.size.x
		info_display.top_unit = unit
		var bottom_unit: Unit = CursorController.hovered_unit
		info_display.bottom_unit = bottom_unit
		info_display.distance = roundi(
			Utilities.get_tile_distance(_selecting_position, bottom_unit.position)
		)
		MapController.get_ui().add_child(info_display)
		CursorController.disable()
		var proceed: bool = await info_display.completed
		CursorController.enable()
		if proceed:
			info_display.queue_free()
			selected.emit(CursorController.hovered_unit)
			close()
