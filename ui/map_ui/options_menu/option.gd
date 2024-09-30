extends RefCounted

var _name: String
var _settings: Array[String]
var _default: int

func _init(name: String, settings: Array[String], default: int = 0) -> void:
	_name = name
	_settings = settings
	_default = default


func get_icon() -> Texture2D:
	return load("res://ui/map_ui/options_menu/icons/%s.png" % _name.to_snake_case())


func get_name() -> String:
	return _name


func get_settings() -> Array[String]:
	return _settings


func get_default_setting() -> int:
	return _default
