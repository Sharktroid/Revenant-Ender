## A class that represents an option.
extends RefCounted

# The option's name
var _name: String
# The option's possible settings
var _settings: Array[String]
# The option's default setting index
var _default: int

func _init(name: String, settings: Array[String], default: int = 0) -> void:
	_name = name
	_settings = settings
	_default = default


## Gets the option's icon.
func get_icon() -> Texture2D:
	return load("res://ui/map_ui/options_menu/icons/%s.png" % _name.to_snake_case())


## Gets the option's name.
func get_name() -> String:
	return _name


## Gets the option's possible settings.
func get_settings() -> Array[String]:
	return _settings


## Gets the option's default setting index.
func get_default_setting() -> int:
	return _default
