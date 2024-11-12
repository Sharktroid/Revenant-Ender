## A [ConfigOption] for a boolean value.
class_name BooleanOption
extends ConfigOption

## The value for the option.
var value: bool:
	set(new_value):
		_value = var_to_str(new_value)
	get:
		return str_to_var(_value)


func _init(name: StringName, category: StringName, default_on: bool, description: String) -> void:
	_name = name
	_category = category
	_default = var_to_str(default_on)
	_description = description
	super()


## Inverts the value.
func invert() -> void:
	value = not value
