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
	$"Resize Handler".set_size.call_deferred(Vector2(size.x * (float(max_value) / ABSOLUTE_MAX_VALUE), $"Resize Handler".size.y))

	var class_base_stat: int = unit.unit_class.base_stats.get(stat, 0)
	var personal_base_stat: int = unit.get_true_personal_base_stat(stat)
	var class_final_stat: int = unit.unit_class.end_stats.get(stat, 0)
	var personal_final_stat: int = unit.personal_end_stats.get(stat, 0)
	var class_stat_cap: int = unit.unit_class.stat_caps.get(stat, 0)
	var personal_stat_cap: int = unit.personal_stat_caps.get(stat, 0)
	var get_growth: Callable = func(final_stat, base_stat, max_level, base_level) -> int:
		return round((final_stat - base_stat)*100/(max_level - base_level))
	var class_growth: int = get_growth.call(class_final_stat, class_base_stat, unit.unit_class.max_level, 1)
	var personal_growth: int = get_growth.call(personal_final_stat, personal_base_stat, unit.get_max_level(), unit.base_level)
	var combine: Callable = func(class_stat: int, personal_stat: int, suffix: String = "") -> String:
		if personal_base_stat == 0 and personal_final_stat == 0 and personal_stat_cap == 0:
			return "%d%s" % [class_stat, suffix]
		if personal_stat < 0:
			return "%d%s - %d%s" % [class_stat, suffix, -personal_stat, suffix]
		else:
			return "%d%s + %d%s" % [class_stat, suffix, personal_stat, suffix]
	var items: Dictionary = {
		"Base" = combine.call(class_base_stat, personal_base_stat),
		"Final" = combine.call(class_final_stat, personal_final_stat),
		"Max" = combine.call(class_stat_cap, personal_stat_cap),
		"Growth" = combine.call(class_growth, personal_growth, "%")
	}
	help_description = GenFunc.dict_to_table(items, 2)
