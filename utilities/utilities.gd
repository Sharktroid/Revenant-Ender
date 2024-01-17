@tool
extends Node

const adjacent_tiles: Array[Vector2i] = [Vector2i(16, 0), Vector2i(-16, 0),
	Vector2i(0, 16), Vector2i(0, -16)]
var theme: Theme = preload("res://ui/theme/menu_theme.tres")
@onready var font_yellow: String = theme.get_color("font_color", "YellowLabel").to_html()
@onready var font_blue: String = theme.get_color("font_color", "BlueLabel").to_html()

var _frame_delta: float
var _debug_constants: Dictionary = { # Constants used in the debug menu.
	unit_wait = true, # Whether units are unable to move after movement.
	display_map_borders = false, # Whether map borders are displayed
	display_map_terrain = false,
	display_map_cursor = false,
}
var _config_file := ConfigFile.new() # File used for saving and loading of configuration settings.
var _default_screen_size: Vector2i
var _profile: Array[int] = []
var _current_checkpoint: int


func _ready() -> void:
	_load_config()
	var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	_default_screen_size = Vector2i(width, height)


func _exit_tree() -> void:
	save_config()


func _process(delta: float) -> void:
	_frame_delta = delta


func get_screen_size() -> Vector2i:
	return _default_screen_size


func save_config() -> void:
	# Saves configuration.
	for constant: String in _debug_constants:
		_config_file.set_value("Debug", constant, get_debug_constant(constant))
	# warning-ignore:return_value_discarded
	_config_file.save("user://config.ini")


func get_debug_constant(constant: String):
	return _debug_constants[constant]


func set_debug_constant(constant: String, value: Variant) -> void:
	_debug_constants[constant] = value
	save_config()


## Gets the amount of time that has elapsed since the previous frame.
func get_frame_delta() -> float:
	return _frame_delta


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
	var seconds: float = float(Time.get_ticks_msec())/1000
	var seconds_mod: float = fmod(seconds, animation_player.current_animation_length)
	animation_player.seek(seconds_mod)


func switch_tab(tab_container: TabContainer, move_to: int) -> void:
	var next_tab: int = tab_container.current_tab + move_to
	tab_container.current_tab = posmod(next_tab, tab_container.get_tab_count())


func xor(condition_a: bool, condition_b: bool) -> bool:
	var result = bool(int(condition_a) ^ int(condition_b))
	return result


func dict_to_table(dict: Dictionary, size: int) -> String:
	var table: String = "[table=%d]" % size
	for key in dict:
		var value = dict[key]
		var replacements: Array = [
			Utilities.font_yellow,
			str(key),
			Utilities.font_blue,
			str(value).lpad(5),
		]
		table += "[cell][color=%s]%s[/color]\t[color=%s]%s[/color][/cell]" % replacements
	return table + "[/table]"


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
		var usec: float = float(_profile[checkpoint])
		print("Checkpoint %s: %s ms" % [checkpoint, usec / 1000])
		sum += usec
	print("Total length: %s ms" % (sum / 1000))


func get_properties(objects: Array, property_path: StringName) -> Array:
	var output_array: Array = []
	for object: Object in objects:
		output_array.append(object.get(property_path))
	return output_array


func _load_config() -> void:
	# Loads configuration
	_config_file.load("user://config.ini")
	for constant: String in _debug_constants:
		var new_constant = get_debug_constant(constant)
		_debug_constants[constant] = _config_file.get_value("Debug", constant, new_constant)
