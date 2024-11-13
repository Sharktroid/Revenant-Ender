## A [ConfigOption] for a floating point value.
class_name FloatOption
extends ConfigOption

## The value for the option.
var value: float:
	set(new_value):
		_value = var_to_str(clampf(new_value, _min, _max))
	get:
		return str_to_var(_value)
var _min: float
var _max: float


func _init(
	name: StringName,
	category: StringName,
	default: float,
	minimum: float,
	maximum: float,
	description: String
) -> void:
	_name = name
	_category = category
	_default = var_to_str(default)
	_description = description
	_min = minimum
	_max = maximum
	super()


## Gets the minimum value of the value.
func get_min() -> float:
	return _min

## Gets the maximum value of the value.
func get_max() -> float:
	return _max
