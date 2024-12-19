@tool
class_name StatBar
extends HelpContainer

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: int = ceili(
	30 + (Unit.PV_MAX_MODIFIER) + (Unit.EV_MAX_MODIFIER)
)

## The unit whose stat is displayed
var unit: Unit
## The stat being displayed
var stat: Unit.Stats:
	set(value):
		stat = value
		_update.call_deferred()


func _update() -> void:
	var current_value: float = unit.get_stat(stat)
	var max_value: float = maxi(unit.get_stat_cap(stat), 10)
	var numeric_progress_bar := $NumericProgressBar as NumericProgressBar

	numeric_progress_bar.max_value = max_value
	if stat == Unit.Stats.SPEED:
		numeric_progress_bar.value = unit.get_attack_speed()
		numeric_progress_bar.original_value = current_value
	else:
		numeric_progress_bar.value = current_value
	numeric_progress_bar.set_size.call_deferred(
		Vector2(size.x * (float(max_value) / ABSOLUTE_MAX_VALUE), numeric_progress_bar.size.y)
	)

	help_table = unit.get_stat_table(stat)
	table_columns = 4
