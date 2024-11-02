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
			var map_borders := (
				MapController.map.get_node("MapLayer/DebugBorderOverlayContainer") as Node2D
			)
			map_borders.visible = DebugConfig.DISPLAY_MAP_BORDERS.value

		"DisplayTerrain":
			DebugConfig.DISPLAY_MAP_TERRAIN.invert()
			var terrain_layer := MapController.map.get_node("MapLayer/TerrainLayer") as TileMapLayer
			terrain_layer.visible = DebugConfig.DISPLAY_MAP_TERRAIN.value

		"DisplayMapCursor":
			DebugConfig.DISPLAY_MAP_CURSOR.invert()
			var cursor_area: Area2D = CursorController.get_area()
			cursor_area.visible = DebugConfig.DISPLAY_MAP_CURSOR.value

		"PrintInputRECEIVER":
			DebugConfig.PRINT_INPUT_RECEIVER.invert()

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
			DebugConfig.SHOW_FPS.invert()
			(GameController.get_root().get_node("%FPSDisplay") as HBoxContainer).visible = (
				DebugConfig.SHOW_FPS.value
			)

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
