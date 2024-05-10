@tool
class_name StatBar
extends HelpContainer

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: int = ceili(
	30 * (Unit.PERSONAL_VALUE_MULTIPLIER) * (Unit.EFFORT_VALUE_MULTIPLIER)
)

var margins: Vector2i

var unit: Unit
var stat: Unit.Stats


func update() -> void:
	var current_value: float = unit.get_stat(stat)
	var max_value: float = maxi(unit.get_stat_cap(stat), 10)

	(%ValueLabel as Label).text = str(roundi(current_value))
	var progress_bar := %ProgressBar as ProgressBar
	if max_value <= 0:
		progress_bar.visible = false
	else:
		progress_bar.visible = true
		progress_bar.max_value = max_value
		progress_bar.value = current_value
	var resize_handler := $ResizeHandler as ReferenceRect
	resize_handler.set_size.call_deferred(
		Vector2(size.x * (float(max_value) / ABSOLUTE_MAX_VALUE), resize_handler.size.y)
	)

	help_table = unit.get_stat_table(stat)
	table_columns = 4
