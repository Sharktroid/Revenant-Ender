extends Node

## The infinite character.
const INF_CHAR: String = "∞"

const _MIN_POSITION: int = -(2 ** 15) + 1
const _SIZE: int = 2 ** 16

var _theme: Theme = preload("res://ui/theme/menu_theme.tres")
var _default_screen_size: Vector2i
var _profile: Array[int] = []
var _current_checkpoint: int
#gdlint: disable = class-variable-name
## The yellow font color.
@onready var FONT_YELLOW: String:
	get:
		return _theme.get_color("font_color", "YellowLabel").to_html()
## The blue font color.
@onready var FONT_BLUE: String:
	get:
		return _theme.get_color("font_color", "BlueLabel").to_html()
#gdlint: enable = class-variable-name


func _init() -> void:
	assert(INF_CHAR.length() == 1, "Error: Infinity character has been corrupted.")
	_default_screen_size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width") as int,
		ProjectSettings.get_setting("display/window/size/viewport_height") as int
	)
	await ready


## Gets the tiles around the center within range.
func get_tiles(
	center: Vector2i,
	true_max_range: float,
	min_range: int = 0,
	boundaries := Rect2i(_MIN_POSITION, _MIN_POSITION, _SIZE, _SIZE)
) -> Set:
	var output := Set.new()
	if true_max_range == INF:
		var tile_blacklist: Dictionary[Vector2i, bool] = {}
		if min_range > 0:
			for tile: Vector2i in get_tiles(center, min_range - 1, 0, boundaries):
				tile_blacklist[tile] = true
		for x: int in range(boundaries.position.x, boundaries.end.x, 16):
			var valid_ys: Array[int] = []
			var is_y_valid: Callable = func(y: int) -> bool:
				return not tile_blacklist.get(Vector2i(x, y))
			valid_ys.assign(range(boundaries.position.y, boundaries.end.y, 16).filter(is_y_valid))
			output.append_array(valid_ys.map(func(y: int) -> Vector2i: return Vector2i(x, y)))
	else:
		if min_range > true_max_range:
			return output
		var max_range: int = roundi(true_max_range)
		var get_ranges: Callable = _get_ranges.bind(max_range, boundaries)
		for x: int in range(
			maxi(-max_range * 16 + center.x, boundaries.position.x),
			mini(max_range * 16 + center.x, boundaries.end.x - 16) + 1,
			16
		):
			var ranges: Array = (get_ranges.call(x, center, min_range) as Array).map(
				func(y: int) -> Vector2i: return Vector2i(x, y)
			)
			output.append_array(ranges)
	return output


## Gets the size of the screen
func get_screen_size() -> Vector2i:
	return _default_screen_size


## Gets the distance between two tiles in tiles.
func get_tile_distance(pos_a: Vector2, pos_b: Vector2) -> float:
	return (absf(pos_a.x - pos_b.x) + absf(pos_a.y - pos_b.y)) / 16


## Rounds "coords" to the nearest tile (16x16).
func round_coords_to_tile(coords: Vector2, offset := Vector2()) -> Vector2i:
	coords -= offset
	return Vector2(floori(coords.x / 16) * 16, floori(coords.y / 16) * 16) + offset


## Syncs the animation to the current time.
func sync_animation(animation_player: AnimationPlayer) -> void:
	animation_player.seek(
		fmod(float(Time.get_ticks_msec()) / 1000, animation_player.current_animation_length)
	)


## Switches tab based off of an offset.
func switch_tab(tab_container: TabContainer, move_to: int) -> void:
	tab_container.current_tab = posmod(
		tab_container.current_tab + move_to, tab_container.get_tab_count()
	)


## Returns true if one value is true and the other is false.
func xor(condition_a: bool, condition_b: bool) -> bool:
	return not (condition_a == condition_b)


## Starts measuring execution time.
func start_profiling() -> void:
	_profile = []
	_current_checkpoint = Time.get_ticks_usec()


## Creates a checkpoint to be output when finishing profiling.
func profiler_checkpoint() -> void:
	_profile.append(Time.get_ticks_usec() - _current_checkpoint)
	_current_checkpoint = Time.get_ticks_usec()


## Stops measuring execution time, displaying every checkpoint.
func finish_profiling() -> void:
	profiler_checkpoint()
	var sum: float = 0
	if _profile.size() > 1:
		for checkpoint: int in _profile.size():
			var usec := float(_profile[checkpoint])
			print("Checkpoint %s: %s ms" % [checkpoint, usec / 1000])
			sum += usec
		print("Total length: %s ms" % (sum / 1000))
	else:
		print("Total length: %s ms" % (_profile[0] as float / 1000))


## Sets the focus path to the nearest neighbor
func set_neighbor_path(
	neighbor_name: String, index: int, modifier: int, parent: Array[Node]
) -> void:
	var new_index: int = index + modifier
	if new_index >= 0 and new_index < parent.size() and parent[new_index] is HelpContainer:
		parent[index].set(
			"focus_neighbor_%s" % neighbor_name, parent[index].get_path_to(parent[new_index])
		)


## Gets the closest control within the control array to the checking control's center
func get_control_within_height(checking_control: Control, control_array: Array[Control]) -> Control:
	var get_distance: Callable = _get_distance.bind(checking_control)
	var closest_control := control_array[0] as Control
	for control: Control in control_array.slice(1) as Array[Control]:
		if get_distance.call(control) < get_distance.call(closest_control):
			closest_control = control
	return closest_control


## Returns true if the engine is running the whole project.
func is_running_project() -> bool:
	const Renderer: GDScript = preload("res://renderer/renderer.gd")
	return get_tree().root.get_child(-1) is Renderer


## Converts a float to a string, using the infinite character.
func float_to_string(num: float, to_int: bool = false) -> String:
	if abs(num) == INF:
		return INF_CHAR if signf(num) == 1.0 else "-%s" % INF_CHAR
	else:
		return str(roundi(num)) if to_int else str(num)


## Returns a substring where the first "start" characters and last "end" characters are removed.
func slice_string(string: String, start: int, end: int) -> String:
	return string.substr(start, string.length() - start - end)


## Converts an array of enums to an integer containing their bitwise representations.
func to_flag(...enums: Array) -> int:
	var flags: int = 0
	for e: int in enums:
		flags += 1 << e
	return flags


func _get_ranges(
	x: int, center: Vector2i, min_range: int, max_range: int, boundaries: Rect2i
) -> Array:
	var top_bound: int = -max_range * 16 + center.y
	var bottom_bound: int = max_range * 16 + center.y
	var x_offset: int = -abs(x - center.x)
	var current_min: int = x_offset + min_range * 16
	var top_max: int = maxi(-x_offset + top_bound, boundaries.position.y)
	var bottom_max: int = mini(x_offset + bottom_bound, boundaries.end.y - 16)
	if current_min > 0:
		var ranges: Array = []
		if -current_min + center.y >= top_bound:
			ranges += range(top_max, -current_min + center.y + 1, 16)
		if current_min + center.y <= bottom_bound:
			ranges += range(current_min + center.y, bottom_max + 1, 16)
		return ranges
	else:
		return range(top_max, bottom_max + 1, 16)


func _get_center(control: Control) -> float:
	return control.get_screen_position().y + control.size.y / 2


func _get_distance(control_a: Control, control_b: Control) -> float:
	return absf(_get_center(control_a) - _get_center(control_b))
