@tool
class_name StatBar
extends HelpContainer

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: float = 35

var margins: Vector2i

var unit: Unit
var stat: Unit.stats


func update() -> void:
	var current_value: float = unit.get_stat(stat)
	var max_value: float = unit.get_stat_cap(stat)

	%"Value Label".text = str(roundi(current_value))
	if max_value <= 0:
		%ProgressBar.visible = false
	else:
		%ProgressBar.visible = true
		%ProgressBar.max_value = max_value
		%ProgressBar.value = current_value
	var new_x: float = size.x * (float(max_value) / ABSOLUTE_MAX_VALUE)
	$"Resize Handler".set_size.call_deferred(Vector2(new_x, $"Resize Handler".size.y))

	help_description = unit.get_stat_table(stat)
