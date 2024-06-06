extends MapMenu


func _init() -> void:
	_to_center = true


func _enter_tree() -> void:
	_update_items()
	super()


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"UnitWait":
			Utilities.invert_debug_value(Utilities.DebugConfigKeys.UNIT_WAIT)

		"DisplayBorders":
			Utilities.invert_debug_value(Utilities.DebugConfigKeys.DISPLAY_MAP_BORDERS)
			var map_borders := (
				MapController.map.get_node("MapLayer/DebugBorderOverlayContainer") as Node2D
			)
			map_borders.visible = Utilities.get_debug_value(
				Utilities.DebugConfigKeys.DISPLAY_MAP_BORDERS
			)

		"DisplayTerrain":
			Utilities.invert_debug_value(Utilities.DebugConfigKeys.DISPLAY_MAP_TERRAIN)
			var terrain_layer := MapController.map.get_node("MapLayer/TerrainLayer") as TileMap
			terrain_layer.visible = Utilities.get_debug_value(
				Utilities.DebugConfigKeys.DISPLAY_MAP_TERRAIN
			)

		"DisplayMapCursor":
			Utilities.invert_debug_value(Utilities.DebugConfigKeys.DISPLAY_MAP_CURSOR)
			var cursor_area: Area2D = CursorController.get_area()
			cursor_area.visible = Utilities.get_debug_value(
				Utilities.DebugConfigKeys.DISPLAY_MAP_CURSOR
			)

		"Print Input Reciever":
			Utilities.invert_debug_value(Utilities.DebugConfigKeys.PRINT_INPUT_RECIEVER)

		"PrintCursorPosition":
			print(
				"Position relative to UI: {screen_pos}\nPosition relative to map: {map_pos}".format(
					{
						"screen_pos": CursorController.screen_position,
						"map_pos": CursorController.map_position
					}
				)
			)

		"DisplayFrameRate":
			Utilities.invert_debug_value(Utilities.DebugConfigKeys.SHOW_FPS)
			(MapController.get_ui().get_node("FPS Display") as HBoxContainer).visible = (
				Utilities.get_debug_value(Utilities.DebugConfigKeys.SHOW_FPS)
			)

		_:
			push_error("%s is not a valid menu item" % item)
	Utilities.save_config()
	_update_items()
	super(item)


func _update_items() -> void:
	var values: Dictionary = {
		"UnitWait": Utilities.get_debug_value(Utilities.DebugConfigKeys.UNIT_WAIT),
		"DisplayBorders":
		Utilities.get_debug_value(Utilities.DebugConfigKeys.DISPLAY_MAP_BORDERS),
		"DisplayTerrain":
		Utilities.get_debug_value(Utilities.DebugConfigKeys.DISPLAY_MAP_TERRAIN),
		"DisplayMapCursor":
		Utilities.get_debug_value(Utilities.DebugConfigKeys.DISPLAY_MAP_CURSOR),
		"PrintInputReciever":
		Utilities.get_debug_value(Utilities.DebugConfigKeys.PRINT_INPUT_RECIEVER),
		"DisplayFrameRate": Utilities.get_debug_value(Utilities.DebugConfigKeys.SHOW_FPS),
	}
	for key: String in values.keys() as Array[String]:
		var value: String = str(values[key])
		($Items.get_node(key) as MapMenuItem).value = value
