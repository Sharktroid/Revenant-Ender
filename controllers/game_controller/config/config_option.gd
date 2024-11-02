## A class that automatically stores a value in config.cfg.
class_name ConfigOption
extends RefCounted

var _name: StringName
var _category: StringName
var _value: StringName:
	set(value):
		_value = value
		_file.set_value(_category, _name, _value)
		_file.save("user://config.cfg")
var _default: StringName
static var _file: ConfigFile


func _init() -> void:
	if not _file:
		_file = ConfigFile.new()
		_file.load("user://config.cfg")
	_value = _file.get_value(_category, _name, _default)


## Gets the name. This is used in the config file as the key.
func get_name() -> StringName:
	return _name
