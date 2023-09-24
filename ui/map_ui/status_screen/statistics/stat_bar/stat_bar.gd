@tool
class_name StatBar
extends HelpContainer

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: float = 35

var margins: Vector2i

var observing_unit: Unit
var observing_stat: Unit.stats


func update() -> void:
	var current_value: float = observing_unit.get_stat(observing_stat)
	var max_value: float = observing_unit.get_stat_cap(observing_stat)

	%"Value Label".text = str(roundi(current_value))
	if max_value <= 0:
		%ProgressBar.visible = false
	else:
		%ProgressBar.visible = true
		%ProgressBar.max_value = max_value
		%ProgressBar.value = current_value
	$"Resize Handler".set_size.call_deferred(Vector2(size.x * (float(max_value) / ABSOLUTE_MAX_VALUE), $"Resize Handler".size.y))

	var final_value: float = observing_unit.get_stat(observing_stat, observing_unit.get_max_level())
	var base_value: float = observing_unit.get_stat(observing_stat, observing_unit.base_level)
	var max_level: float = observing_unit.get_max_level()
	var base_level: float = observing_unit.base_level
	var items: Dictionary = {
		"Base" = base_value,
		"Final" = final_value,
		"Max" = max_value,
		"Growth" = str(round((final_value - base_value)*100/(max_level - base_level))) + "%"
	}
	help_description = GenFunc.dict_to_table(items, 2)
