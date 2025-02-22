extends MapMenu


func _init() -> void:
	_to_center = true


func _exit_tree() -> void:
	CursorController.enable()


static func instantiate(new_offset: Vector2, parent: MapMenu = null) -> MapMenu:
	return _base_instantiate(
		preload("res://ui/map_ui/map_menus/debug_commands_menu/debug_commands_menu.tscn"),
		new_offset,
		parent
	)


func _select_item(item: MapMenuItem) -> void:
	match item.name:
		"PrintCursorPosition":
			print(_get_cursor_position())
		_:
			push_error("%s is not a valid menu item" % item)
	super(item)


func _get_cursor_position() -> String:
	var format_dictionary: Dictionary = {
		"ui": "Position relative to UI: %s" % CursorController.screen_position,
		"map": "Position relative to map: %s" % CursorController.map_position
	}
	return "{ui}\n{map}".format(format_dictionary)
