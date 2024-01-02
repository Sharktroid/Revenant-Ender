class_name AttackSelector
extends UnitSelector

func _position_selected() -> void:
	if _can_select():
		var info_display: PanelContainer = \
				preload("res://ui/combat_info_display/combat_info_display.tscn").instantiate()
		if (MapController.get_cursor().position.x <
				(GenVars.get_screen_size().x as float / 2)):
			info_display.position.x = GenVars.get_screen_size().x - info_display.size.x
		info_display.top_unit = unit
		info_display.bottom_unit = MapController.get_cursor().get_hovered_unit()
		MapController.get_ui().add_child(info_display)
		info_display.grab_focus()
		if await info_display.complete:
			info_display.queue_free()
			emit_signal.call_deferred("selected", MapController.get_cursor().get_hovered_unit())
			close()
		else:
			grab_focus()
