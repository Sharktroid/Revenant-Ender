extends "res://Menus/Map Menus/base_map_menu.gd"

func _init():
	items = get_items()


func get_items() -> Array[String]:
	return [
		"Unit Wait: %s" % GenVars.get_debug_constant("unit_wait"),
		"Display Borders: %s" % GenVars.get_debug_constant("display_map_borders"),
		"Display Terrain: %s" % GenVars.get_debug_constant("display_map_terrain"),
		"Display Map Cursor: %s" % GenVars.get_debug_constant("display_map_cursor"),
		"Print Cursor Position",
	]


func _on_button_pressed(button: Button) -> void:
	match (button.text+":").split(":")[0]:
		"Unit Wait":
			GenVars.invert_debug_constant("unit_wait")

		"Display Borders":
			GenVars.invert_debug_constant("display_map_borders")
			var map_borders: Node2D = GenVars.get_map().get_node("Debug Border Overlay Container")
			map_borders.visible = GenVars.get_debug_constant("display_map_borders")

		"Display Terrain":
			GenVars.invert_debug_constant("display_map_terrain")
			print_debug(GenVars.get_debug_constant("display_map_terrain"))
			var terrain_layer: TileMap = GenVars.get_map().get_node("Terrain Layer")
			terrain_layer.visible = GenVars.get_debug_constant("display_map_terrain")

		"Display Map Cursor":
			GenVars.invert_debug_constant("display_map_cursor")
			GenVars.get_cursor().get_area().visible = GenVars.get_debug_constant("display_map_cursor")

		"Print Cursor Position":
			var replacements: Array[Vector2i] = [
				GenVars.get_cursor().get_rel_pos(),
				GenVars.get_cursor().get_true_pos()
			]
			print("Position relative to UI: %s\nPosition relative to map: %s" % replacements)

		var item: push_error("%s is not a valid menu item" % item)
	GenVars.save_config()
	super._on_button_pressed(button)


func close() -> void:
	super.close()
	GenVars.get_level_controller().get_node("UILayer/Main Map Menu").set_active(true)
