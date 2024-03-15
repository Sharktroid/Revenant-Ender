extends MapMenu


func _enter_tree() -> void:
	_update_items()
	super()


func select_item(item: MapMenuItem) -> void:
	match item.name:
		"Unit Wait":
			Utilities.invert_debug_constant("unit_wait")

		"Display Borders":
			Utilities.invert_debug_constant("display_map_borders")
			var map_borders := \
					MapController.map.get_node("Map Layer/Debug Border Overlay Container") as Node2D
			map_borders.visible = Utilities.get_debug_constant("display_map_borders")

		"Display Terrain":
			Utilities.invert_debug_constant("display_map_terrain")
			var terrain_layer := MapController.map.get_node("Map Layer/Terrain Layer") as TileMap
			terrain_layer.visible = Utilities.get_debug_constant("display_map_terrain")

		"Display Map Cursor":
			Utilities.invert_debug_constant("display_map_cursor")
			var cursor_area: Area2D = CursorController.get_area()
			cursor_area.visible = Utilities.get_debug_constant("display_map_cursor")

		"Print Cursor Position":
			var replacements: Array[Vector2i] = [
				CursorController.get_screen_position(),
				CursorController.get_map_position()
			]
			print("Position relative to UI: %s\nPosition relative to map: %s" % replacements)

		_: push_error("%s is not a valid menu item" % item)
	Utilities.save_config()
	_update_items()
	super(item)


func _update_items() -> void:
	var values: Dictionary = {
		"Unit Wait": Utilities.get_debug_constant("unit_wait"),
		"Display Borders": Utilities.get_debug_constant("display_map_borders"),
		"Display Terrain": Utilities.get_debug_constant("display_map_terrain"),
		"Display Map Cursor": Utilities.get_debug_constant("display_map_cursor"),
	}
	for key: String in values.keys() as Array[String]:
		var value: String = str(values[key])
		($Items.get_node(key) as MapMenuItem).value = value
