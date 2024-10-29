extends Node

# Constants used in the debug menu.
var _config: Dictionary
# File used for saving and loading of configuration settings.
var _config_file := ConfigFile.new()
var _category: String


func _init() -> void:
	_load_config()


func get_value(key: StringName) -> Variant:
	return _config[key]


func set_value(key: StringName, value: Variant) -> void:
	_config[key] = value
	_config_file.set_value(_category, key, _config[key])
	_config_file.save("user://config.cfg")


func invert_value(key: StringName) -> void:
	set_value(key, not get_value(key))


func _load_config() -> void:
	# Loads configuration
	_config_file.load("user://config.cfg")
	for key: String in _config.keys() as Array[String]:
		_config[key] = _config_file.get_value(_category, key, _config[key])
