# General functions used throughout ES
# General functions used throughout ES
class_name GenFunc

static func slice_string(string: String, start: int, end: int) -> String:
	# Returns a substring of "string" from index "start" to index "end"
	return string.substr(start, string.length() - start - end)


#static func randomize_array(array: Array) -> Array:
#	# Returns a randomized version of "array"
#	var random_array = []
#	for i in len(array):
#		var idx = randi() % len(array)
#		random_array.append(array.pop_at(idx))
#	return random_array


static func clamp_vector(vector: Vector2, min_vector: Vector2, max_vector: Vector2) -> Vector2:
	# Clamps the values of "vector" to between those of "min_vector" and "max_vector".
	for i in range(2):
		vector[i] = clamp(vector[i], min_vector[i], max_vector[i])
	return vector


static func get_tile_distance(pos_a: Vector2, pos_b: Vector2) -> float:
	# Gets the distance between two tiles in tiles.
	return (abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y))/16


#static func create_map_menu(parent: Node, name: String, items: Array, pos: Vector2, index: int = 0) -> Control:
#	# Creates a new map menu.
#	# parent: parent of the new menu.
#	# name: name of the new menu.
#	# items: the menu items.
#	# pos: the position relative to parent.
#	var menu: MapMenu = load("map_menu.tscn").instantiate()
#	menu.name = "%s Menu" % name
#	menu.items = items
#	menu._index = index
#	menu.position = pos
#	menu.create_menu()
#	var formatted_name = name.to_lower().replace(" ", "_")
#	# warning-ignore:return_value_discarded
#	menu.connect("item_selected",Callable(parent,"_on_%s_menu_select_item" % formatted_name))
#	# warning-ignore:return_value_discarded
#	menu.connect("menu_closed",Callable(parent,"_on_%s_menu_closed" % formatted_name))
#	GenVars.get_game_controller().get_node("UILayer").add_child(menu)
#	return menu


static func round_coords_to_tile(coords: Vector2, offset := Vector2()) -> Vector2i:
	# Rounds "coords" to the nearest tile (16x16).
	coords -= offset
	coords = Vector2(floor(coords.x/16) * 16, floor(coords.y/16) * 16)
	return coords + offset
