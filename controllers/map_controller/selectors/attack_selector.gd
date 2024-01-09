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
		info_display.bottom_unit = CursorController.get_hovered_unit()
		MapController.get_ui().add_child(info_display)
		info_display.grab_focus()
		if await info_display.complete:
			info_display.queue_free()
			emit_signal.call_deferred("selected", CursorController.get_hovered_unit())
			close()
		else:
			grab_focus()
