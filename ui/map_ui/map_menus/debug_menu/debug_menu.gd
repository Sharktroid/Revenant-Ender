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
			DebugConfig.invert_value(DebugConfig.UNIT_WAIT)

		"DisplayBorders":
			DebugConfig.invert_value(DebugConfig.DISPLAY_MAP_BORDERS)
			var map_borders := (
				MapController.map.get_node("MapLayer/DebugBorderOverlayContainer") as Node2D
			)
			map_borders.visible = DebugConfig.get_value(DebugConfig.DISPLAY_MAP_BORDERS)

		"DisplayTerrain":
			DebugConfig.invert_value(DebugConfig.DISPLAY_MAP_TERRAIN)
			var terrain_layer := MapController.map.get_node("MapLayer/TerrainLayer") as TileMapLayer
			terrain_layer.visible = DebugConfig.get_value(DebugConfig.DISPLAY_MAP_TERRAIN)

		"DisplayMapCursor":
			DebugConfig.invert_value(DebugConfig.DISPLAY_MAP_CURSOR)
			var cursor_area: Area2D = CursorController.get_area()
			cursor_area.visible = DebugConfig.get_value(DebugConfig.DISPLAY_MAP_CURSOR)

		"PrintInputRECEIVER":
			DebugConfig.invert_value(DebugConfig.PRINT_INPUT_RECEIVER)

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
			DebugConfig.invert_value(DebugConfig.SHOW_FPS)
			(GameController.get_root().get_node("%FPSDisplay") as HBoxContainer).visible = (
				DebugConfig.get_value(DebugConfig.SHOW_FPS)
			)

		_:
			push_error("%s is not a valid menu item" % item)
	_update_items()
	super(item)


func _update_items() -> void:
	var values: Dictionary = {
		"UnitWait": DebugConfig.get_value(DebugConfig.UNIT_WAIT),
		"DisplayBorders": DebugConfig.get_value(DebugConfig.DISPLAY_MAP_BORDERS),
		"DisplayTerrain": DebugConfig.get_value(DebugConfig.DISPLAY_MAP_TERRAIN),
		"DisplayMapCursor": DebugConfig.get_value(DebugConfig.DISPLAY_MAP_CURSOR),
		"PrintInputRECEIVER": DebugConfig.get_value(DebugConfig.PRINT_INPUT_RECEIVER),
		"DisplayFrameRate": DebugConfig.get_value(DebugConfig.SHOW_FPS),
	}
	for key: String in values.keys() as Array[String]:
		var value: String = str(values[key])
		($Items.get_node(key) as MapMenuItem).value = value
