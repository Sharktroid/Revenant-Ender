@tool
class_name StatBar
extends Control

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: float = 35

var margins: Vector2i

var current_value: float:
	set(value):
		current_value = value
		_update()
var max_value: float:
	set(value):
		max_value = value
		_update()


func _update() -> void:
	%"Value Label".text = str(roundi(current_value))
	%ProgressBar.max_value = max_value
	%ProgressBar.value = current_value
	$"Resize Handler".size.x = size.x * (float(max_value) / ABSOLUTE_MAX_VALUE)
