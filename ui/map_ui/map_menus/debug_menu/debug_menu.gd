extends MapMenu


func _init() -> void:
	_to_center = true


func _enter_tree() -> void:
	_update_items()
	super()


static func instantiate(new_offset: Vector2, parent: MapMenu = null) -> MapMenu:
	return _base_instantiate(
		preload("res://ui/map_ui/map_menus/debug_menu/debug_menu.tscn"), new_offset, parent
	)


func _select_item(item: MapMenuItem) -> void:
	match item.name:
		"UnitWait":
			DebugConfig.UNIT_WAIT.invert()

		"DisplayBorders":
			DebugConfig.DISPLAY_MAP_BORDERS.invert()

		"DisplayTerrain":
			DebugConfig.DISPLAY_MAP_TERRAIN.invert()

		"DisplayMapCursor":
			DebugConfig.DISPLAY_MAP_CURSOR.invert()

		"PrintInputReciever":
			DebugConfig.PRINT_INPUT_RECEIVER.invert()

		"PrintCursorPosition":
			var format_dictionary: Dictionary = {
				"ui": "Position relative to UI: %s" % CursorController.screen_position,
				"map": "Position relative to map: %s" % CursorController.map_position
			}
			print("{ui}\n{map}".format(format_dictionary))

		"DisplayFrameRate":
			DebugConfig.SHOW_FPS.invert()

		_:
			push_error("%s is not a valid menu item" % item)
	_update_items()
	super(item)


func _update_items() -> void:
	var values: Dictionary = {
		"UnitWait": DebugConfig.UNIT_WAIT.value,
		"DisplayBorders": DebugConfig.DISPLAY_MAP_BORDERS.value,
		"DisplayTerrain": DebugConfig.DISPLAY_MAP_TERRAIN.value,
		"DisplayMapCursor": DebugConfig.DISPLAY_MAP_CURSOR.value,
		"PrintInputRECEIVER": DebugConfig.PRINT_INPUT_RECEIVER.value,
		"DisplayFrameRate": DebugConfig.SHOW_FPS.value,
	}
	for key: String in values.keys() as Array[String]:
		var value: String = str(values[key])
		($Items.get_node(key) as MapMenuItem).value = value
