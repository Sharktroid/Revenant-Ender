@tool
extends Node

const adjacent_tiles: Array[Vector2i] = [Vector2i(16, 0), Vector2i(-16, 0),
	Vector2i(0, 16), Vector2i(0, -16)]
var theme: Theme = preload("res://ui/theme/menu_theme.tres")
@onready var font_yellow: String = theme.get_color("font_color", "YellowLabel").to_html()
@onready var font_blue: String = theme.get_color("font_color", "BlueLabel").to_html()

var _debug_constants: Dictionary = { # Constants used in the debug menu.
	unit_wait = true, # Whether units are unable to move after movement.
	display_map_borders = false, # Whether map borders are displayed
	display_map_terrain = false,
	display_map_cursor = false,
	print_input_reciever = false,
}
var _config_file := ConfigFile.new() # File used for saving and loading of configuration settings.
var _default_screen_size: Vector2i
var _profile: Array[int] = []
var _current_checkpoint: int


func _init() -> void:
	_load_config()
	_default_screen_size = Vector2i(
			ProjectSettings.get_setting("display/window/size/viewport_width") as int,
			ProjectSettings.get_setting("display/window/size/viewport_height") as int)


func _exit_tree() -> void:
	save_config()


func get_screen_size() -> Vector2i:
	return _default_screen_size


func save_config() -> void:
	# Saves configuration.
	for constant: String in _debug_constants.keys() as Array[String]:
		_config_file.set_value("Debug", constant, get_debug_constant(constant))
	# warning-ignore:return_value_discarded
	_config_file.save("user://config.ini")


func get_debug_constant(constant: String) -> Variant:
	return _debug_constants[constant]


func set_debug_constant(constant: String, value: Variant) -> void:
	_debug_constants[constant] = value
	save_config()


func invert_debug_constant(constant: String) -> void:
	set_debug_constant(constant, not(get_debug_constant(constant)))


func slice_string(string: String, start: int, end: int) -> String:
	# Returns a substring of "string" from index "start" to index "end"
	return string.substr(start, string.length() - start - end)


func get_tile_distance(pos_a: Vector2, pos_b: Vector2) -> float:
	# Gets the distance between two tiles in tiles.
	return (absf(pos_a.x - pos_b.x) + absf(pos_a.y - pos_b.y))/16


func round_coords_to_tile(coords: Vector2, offset := Vector2()) -> Vector2i:
	# Rounds "coords" to the nearest tile (16x16).
	coords -= offset
	coords = Vector2(floori(coords.x/16) * 16, floori(coords.y/16) * 16)
	return coords + offset


func sync_animation(animation_player: AnimationPlayer) -> void:
	animation_player.seek(fmod(float(Time.get_ticks_msec())/1000,
			animation_player.current_animation_length))


func switch_tab(tab_container: TabContainer, move_to: int) -> void:
	tab_container.current_tab = posmod(tab_container.current_tab + move_to,
			tab_container.get_tab_count())


func xor(condition_a: bool, condition_b: bool) -> bool:
	return !(condition_a == condition_b)


func dict_to_table(dict: Dictionary) -> Array[String]:
	var table: Array[String] = []
	for key: String in dict.keys() as Array[String]:
		table.append_array([
			"[color=%s]%s[/color]" % [Utilities.font_yellow, str(key)],
			"[color=%s]%s[/color]" % [Utilities.font_blue, str(dict[key])]
		])
	return table


func start_profiling() -> void:
	_profile = []
	_current_checkpoint = Time.get_ticks_usec()


func profiler_checkpoint() -> void:
	_profile.append(Time.get_ticks_usec() - _current_checkpoint)
	_current_checkpoint = Time.get_ticks_usec()


func finish_profiling() -> void:
	profiler_checkpoint()
	var sum: float = 0
	for checkpoint: int in _profile.size():
		var usec := float(_profile[checkpoint])
		print("Checkpoint %s: %s ms" % [checkpoint, usec / 1000])
		sum += usec
	print("Total length: %s ms" % (sum / 1000))


func get_properties_of_array(objects: Array[Object], property_path: StringName) -> Array:
	var output_array: Array = []
	for object: Object in objects:
		output_array.append(object.get(property_path))
	return output_array


func set_neighbor_path(neighbor_name: String, index: int, modifier: int,
		parent: Array[Node]) -> void:
	var new_index: int = index + modifier
	if (new_index >= 0 and new_index < parent.size() and parent[new_index] is HelpContainer):
		parent[index].set("focus_neighbor_%s" % neighbor_name,
				parent[index].get_path_to(parent[new_index]))


func get_control_within_height(checking_control: Control, control_array: Array[Node]) -> Control:
	var get_center: Callable = func(control: Control) -> float:
		return control.get_screen_position().y + control.size.y / 2
	var center: float = get_center.call(checking_control)
	var get_distance: Callable = func(control: Control) -> float:
		return absf(center - get_center.call(control))

	var closest_control := control_array[0] as Control
	for control: Control in control_array.slice(1) as Array[Control]:
		if get_distance.call(control) < get_distance.call(closest_control):
			closest_control = control
	return closest_control


func _load_config() -> void:
	# Loads configuration
	_config_file.load("user://config.ini")
	for constant: String in _debug_constants.keys() as Array[String]:
		_debug_constants[constant] = _config_file.get_value("Debug", constant,
				get_debug_constant(constant))
