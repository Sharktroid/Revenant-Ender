@tool
extends Node

enum DebugConfigKeys {
	UNIT_WAIT,
	DISPLAY_MAP_BORDERS,
	DISPLAY_MAP_TERRAIN,
	DISPLAY_MAP_CURSOR,
	PRINT_INPUT_RECIEVER,
	SHOW_FPS,
}
const ADJACENT_TILES: Array[Vector2i] = [
	Vector2i(16, 0), Vector2i(-16, 0), Vector2i(0, 16), Vector2i(0, -16)
]

var theme: Theme = preload("res://ui/theme/menu_theme.tres")

var _debug_config: Dictionary = {  # Constants used in the debug menu.
	DebugConfigKeys.UNIT_WAIT: true,  # Whether units are unable to move after movement.
	DebugConfigKeys.DISPLAY_MAP_BORDERS: false,  # Whether map borders are displayed
	DebugConfigKeys.DISPLAY_MAP_TERRAIN: false,
	DebugConfigKeys.DISPLAY_MAP_CURSOR: false,
	DebugConfigKeys.PRINT_INPUT_RECIEVER: false,
	DebugConfigKeys.SHOW_FPS: false
}
var _config_file := ConfigFile.new()  # File used for saving and loading of configuration settings.
var _default_screen_size: Vector2i
var _profile: Array[int] = []
var _current_checkpoint: int

@onready var font_yellow: String = theme.get_color("font_color", "YellowLabel").to_html()
@onready var font_blue: String = theme.get_color("font_color", "BlueLabel").to_html()


func _init() -> void:
	_load_config()
	_default_screen_size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width") as int,
		ProjectSettings.get_setting("display/window/size/viewport_height") as int
	)
	await ready


func _exit_tree() -> void:
	save_config()


func get_tiles(
	center: Vector2i,
	true_max_range: float,
	min_range: int = 0,
	boundaries := Rect2i(0, 0, 16000, 16000)
) -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	if true_max_range == INF:
		var tile_blacklist: Dictionary = {}
		if min_range > 0:
			for tile in get_tiles(center, min_range - 1, 0, boundaries):
				tile_blacklist[tile] = true
		for x: int in range(boundaries.position.x, boundaries.end.x, 16):
			for y: int in range(boundaries.position.y, boundaries.end.y, 16):
				var tile := Vector2i(x, y)
				if not tile_blacklist.get(tile):
					output.append(tile)
	else:
		var max_range: int = roundi(true_max_range)
		if min_range > max_range:
			return output

		var left_bound: int = maxi(-max_range * 16 + center.x, boundaries.position.x)
		var right_bound: int = mini(max_range * 16 + center.x, boundaries.end.x - 16)
		var top_bound: int = -max_range * 16 + center.y
		var bottom_bound: int = max_range * 16 + center.y
		for x: int in range(left_bound, right_bound + 1, 16):
			var x_offset: int = -abs(x - center.x)
			var curr_min: int = x_offset + min_range * 16
			var top_max: int = maxi(-x_offset + top_bound, boundaries.position.y)
			var bottom_max: int = mini(x_offset + bottom_bound, boundaries.end.y - 16)

			var ranges: Array = []
			if curr_min > 0:
				if -curr_min + center.y >= top_bound:
					ranges += range(top_max, -curr_min + center.y + 1, 16)
				if curr_min + center.y <= bottom_bound:
					ranges += range(curr_min + center.y, bottom_max + 1, 16)
			else:
				ranges = range(top_max, bottom_max + 1, 16)
			for y: int in ranges:
				output.append(Vector2i(x, y))
	return output


func get_screen_size() -> Vector2i:
	return _default_screen_size


func save_config() -> void:
	# Saves configuration.
	for constant: String in DebugConfigKeys.keys() as Array[String]:
		_config_file.set_value(
			"Debug",
			constant.to_snake_case(),
			get_debug_value(DebugConfigKeys[constant] as Utilities.DebugConfigKeys)
		)
	_config_file.save("user://config.cfg")


func get_debug_value(key: DebugConfigKeys) -> Variant:
	return _debug_config[key]


func set_debug_value(key: DebugConfigKeys, value: Variant) -> void:
	_debug_config[key] = value
	save_config()


func invert_debug_value(key: DebugConfigKeys) -> void:
	set_debug_value(key, not get_debug_value(key))


func slice_string(string: String, start: int, end: int) -> String:
	# Returns a substring of "string" from index "start" to index "end"
	return string.substr(start, string.length() - start - end)


func get_tile_distance(pos_a: Vector2, pos_b: Vector2) -> float:
	# Gets the distance between two tiles in tiles.
	return (absf(pos_a.x - pos_b.x) + absf(pos_a.y - pos_b.y)) / 16


func round_coords_to_tile(coords: Vector2, offset := Vector2()) -> Vector2i:
	# Rounds "coords" to the nearest tile (16x16).
	coords -= offset
	coords = Vector2(floori(coords.x / 16) * 16, floori(coords.y / 16) * 16)
	return coords + offset


func sync_animation(animation_player: AnimationPlayer) -> void:
	animation_player.seek(
		fmod(float(Time.get_ticks_msec()) / 1000, animation_player.current_animation_length)
	)


func switch_tab(tab_container: TabContainer, move_to: int) -> void:
	tab_container.current_tab = posmod(
		tab_container.current_tab + move_to, tab_container.get_tab_count()
	)


func xor(condition_a: bool, condition_b: bool) -> bool:
	return !(condition_a == condition_b)


func dict_to_table(dict: Dictionary) -> Array[String]:
	var table: Array[String] = []
	for key: String in dict.keys() as Array[String]:
		table.append_array(
			[
				"[color={yellow}]{key}[/color]".format(
					{"yellow": Utilities.font_yellow, "key": str(key)}
				),
				"[color={blue}]{value}[/color]".format(
					{"blue": Utilities.font_blue, "value": str(dict[key])}
				)
			]
		)
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


func set_neighbor_path(
	neighbor_name: String, index: int, modifier: int, parent: Array[Node]
) -> void:
	var new_index: int = index + modifier
	if new_index >= 0 and new_index < parent.size() and parent[new_index] is HelpContainer:
		parent[index].set(
			"focus_neighbor_%s" % neighbor_name, parent[index].get_path_to(parent[new_index])
		)


func get_control_within_height(checking_control: Control, control_array: Array[Control]) -> Control:
	var center: float = _get_center(checking_control)
	var get_distance: Callable = func(control: Control) -> float:
		return absf(center - _get_center(control))

	var closest_control := control_array[0] as Control
	for control: Control in control_array.slice(1) as Array[Control]:
		if get_distance.call(control) < get_distance.call(closest_control):
			closest_control = control
	return closest_control


func is_running_project() -> bool:
	const Renderer = preload("res://renderer/renderer.gd")
	return get_tree().root.get_child(-1) is Renderer


func float_to_string(num: float) -> String:
	return str(num).replace("inf", "∞")


func _get_center(control: Control) -> float:
	return control.get_screen_position().y + control.size.y / 2


func _load_config() -> void:
	# Loads configuration
	_config_file.load("user://config.cfg")
	for constant: String in DebugConfigKeys.keys() as Array[String]:
		var debug_key: DebugConfigKeys = DebugConfigKeys[constant]
		_debug_config[debug_key] = _config_file.get_value(
			"Debug",
			constant.to_snake_case(),
			get_debug_value(debug_key)
		)
