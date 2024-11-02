## A [ConfigOption] for a boolean value.
class_name BooleanOption
extends ConfigOption

## The value for the option.
var value: bool:
	set(new_value):
		_value = str(new_value)
	get:
		return str_to_var(_value)


func _init(name: StringName, category: StringName, default_on: bool) -> void:
	_name = name
	_category = category
	_default = str(default_on)
	super()


## Inverts the value.
func invert() -> void:
	value = not value
