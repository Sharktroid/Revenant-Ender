extends Node

const adjacent_tiles: Array[Vector2i] = [Vector2i(16, 0), Vector2i(-16, 0),
	Vector2i(0, 16), Vector2i(0, -16)]

var _debug_constants: Dictionary = { # Constants used in the debug menu.
	unit_wait = true, # Whether units are unable to move after movement.
	display_map_borders = false, # Whether map borders are displayed
	display_map_terrain = false,
	display_map_cursor = false,
}
var _config_file := ConfigFile.new() # File used for saving and loading of configuration settings.
var default_screen_size: Vector2i


func _ready() -> void:
	_load_config()
	var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	default_screen_size = Vector2i(width, height)

#	elif event.is_action_pressed("debug"):
#		get_cursor_area().monitoring = false
#		get_cursor_area().monitoring = true
#		ProjectSettings.set_setting("display/window/stretch/scale", 3)
#		get_level_controller().set_scaling(10)


func _exit_tree() -> void:
	save_config()


func get_screen_size() -> Vector2i:
	return default_screen_size


func get_game_controller() -> GameController:
	return get_parent().get_node("SubViewportContainer/SubViewport/Game Controller")


func get_level_controller() -> LevelController:
	if get_game_controller():
		return (get_game_controller().get_node("Level Controller") as LevelController)
	else:
		push_error("Could not find Level Controller")
		return null


func get_cursor() -> Cursor:
	return get_level_controller().get_node("UILayer/Cursor")


func get_map() -> Map:
	if get_map_camera():
		return get_map_camera().get_child(0) as Map
	else:
		push_error("Could not find Map")
		return null


func get_map_camera() -> MapCamera:
	if get_level_controller():
		return (get_level_controller().get_node("Map Camera") as MapCamera)
	else:
		push_error("Could not find Map Camera")
		return null


func get_tick_timer() -> float:
	## Returns the amount of elapsed ticks.
	## 60 ticks/second.
	return Time.get_ticks_msec() / 1000.0 * 60


func save_config() -> void:
	# Saves configuration.
	for constant in _debug_constants:
		_config_file.set_value("Debug", constant, get_debug_constant(constant))
	# warning-ignore:return_value_discarded
	_config_file.save("user://config.ini")


func get_debug_constant(constant: String):
	return _debug_constants[constant]


func set_debug_constant(constant: String, value) -> void:
	_debug_constants[constant] = value
	save_config()


func invert_debug_constant(constant: String) -> void:
	set_debug_constant(constant, not(get_debug_constant(constant)))


func _load_config() -> void:
	# Loads configuration
	_config_file.load("user://config.ini")
	for constant in _debug_constants:
		var new_constant = get_debug_constant(constant)
		_debug_constants[constant] = _config_file.get_value("Debug", constant, new_constant)
