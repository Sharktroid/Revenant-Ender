extends MapMenu


func _enter_tree() -> void:
	_update_items()
	super()


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"UnitWait":
			Utilities.invert_debug_constant("unit_wait")

		"DisplayBorders":
			Utilities.invert_debug_constant("display_map_borders")
			var map_borders := \
					MapController.map.get_node("MapLayer/DebugBorderOverlayContainer") as Node2D
			map_borders.visible = Utilities.get_debug_constant("display_map_borders")

		"DisplayTerrain":
			Utilities.invert_debug_constant("display_map_terrain")
			var terrain_layer := MapController.map.get_node("MapLayer/TerrainLayer") as TileMap
			terrain_layer.visible = Utilities.get_debug_constant("display_map_terrain")

		"DisplayMapCursor":
			Utilities.invert_debug_constant("display_map_cursor")
			var cursor_area: Area2D = CursorController.get_area()
			cursor_area.visible = Utilities.get_debug_constant("display_map_cursor")

		"Print Input Reciever":
			Utilities.invert_debug_constant("print_input_reciever")

		"PrintCursorPosition":
			print("Position relative to UI: %s\nPosition relative to map: %s" % [
				CursorController.screen_position,
				CursorController.map_position
			])

		_: push_error("%s is not a valid menu item" % item)
	Utilities.save_config()
	_update_items()
	super(item)


func _update_items() -> void:
	var values: Dictionary = {
		"UnitWait": Utilities.get_debug_constant("unit_wait"),
		"DisplayBorders": Utilities.get_debug_constant("display_map_borders"),
		"DisplayTerrain": Utilities.get_debug_constant("display_map_terrain"),
		"DisplayMapCursor": Utilities.get_debug_constant("display_map_cursor"),
		"OutputInputReciever": Utilities.get_debug_constant("print_input_reciever"),
	}
	for key: String in values.keys() as Array[String]:
		var value: String = str(values[key])
		($Items.get_node(key) as MapMenuItem).value = value
