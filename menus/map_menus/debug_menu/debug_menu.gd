extends MapMenu


func get_items() -> Dictionary:
	return {
		"Unit Wait": func (): return GenVars.get_debug_constant("unit_wait"),
		"Display Borders": func (): return GenVars.get_debug_constant("display_map_borders"),
		"Display Terrain": func (): return GenVars.get_debug_constant("display_map_terrain"),
		"Display Map Cursor": func (): return GenVars.get_debug_constant("display_map_cursor"),
		"Print Cursor Position": null,
	}


func select_item(item: String) -> void:
	match item:
		"Unit Wait":
			GenVars.invert_debug_constant("unit_wait")

		"Display Borders":
			GenVars.invert_debug_constant("display_map_borders")
			var map_borders: Node2D = GenVars.map.get_node("Debug Border Overlay Container")
			map_borders.visible = GenVars.get_debug_constant("display_map_borders")

		"Display Terrain":
			GenVars.invert_debug_constant("display_map_terrain")
			var terrain_layer: TileMap = GenVars.map.get_node("Terrain Layer")
			terrain_layer.visible = GenVars.get_debug_constant("display_map_terrain")

		"Display Map Cursor":
			GenVars.invert_debug_constant("display_map_cursor")
			var cursor_area: Area2D = GenVars.cursor.get_area()
			cursor_area.visible = GenVars.get_debug_constant("display_map_cursor")

		"Print Cursor Position":
			var replacements: Array[Vector2i] = [
				GenVars.cursor.get_rel_pos(),
				GenVars.cursor.get_true_pos()
			]
			print("Position relative to UI: %s\nPosition relative to map: %s" % replacements)

		_: push_error("%s is not a valid menu item" % item)
	GenVars.save_config()
	super(item)


func close() -> void:
	super()
	parent_menu.grab_focus()
	parent_menu.visible = true
