class_name AttackSelector
extends UnitSelector

func _position_selected() -> void:
	if _can_select():
		var info_display: PanelContainer = \
				preload("res://ui/combat_info_display/combat_info_display.tscn").instantiate()
		if (CursorController.get_rel_pos().x + MapController.get_map_camera().get_map_offset().x <
				(Utilities.get_screen_size().x as float / 2)):
			info_display.position.x = Utilities.get_screen_size().x - info_display.size.x
		info_display.top_unit = unit
		var bottom_unit: Unit = CursorController.get_hovered_unit()
		info_display.bottom_unit = bottom_unit
		info_display.distance = Utilities.get_tile_distance(_selecting_position,
				bottom_unit.position)
		MapController.get_ui().add_child(info_display)
		CursorController.disable()
		var proceed: bool = await info_display.complete
		CursorController.enable()
		if proceed:
			info_display.queue_free()
			emit_signal.call_deferred("selected", CursorController.get_hovered_unit())
			close()
