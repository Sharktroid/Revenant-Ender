## A [ConfigOption] that stores a StringName value.
## This is an abstract class; it should be extended.
class_name StringNameOption
extends ConfigOption

## The value that is stored.
var value: StringName:
	set(new_value):
		_value = new_value
	get:
		return _value
var _settings: Array[StringName]


## Returns the possible valid values.
func get_settings() -> Array[StringName]:
	return _settings


func get_error_message() -> String:
	return "ERROR: value %s is invalid" % value
