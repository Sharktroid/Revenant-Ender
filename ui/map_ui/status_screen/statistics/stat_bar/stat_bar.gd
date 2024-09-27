@tool
class_name StatBar
extends HelpContainer

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: int = ceili(
	30 + (Unit.PERSONAL_VALUE_MAX_MODIFIER) + (Unit.EFFORT_VALUE_MAX_MODIFIER)
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
	var is_speed: bool = stat == Unit.Stats.SPEED
	var value_label := %ValueLabel as Label

	if is_speed:
		value_label.text = Utilities.float_to_string(unit.get_attack_speed())
		value_label.theme_type_variation = (
			&"RedLabel" if unit.get_attack_speed() < unit.get_speed() else &"BlueLabel"
		)
	else:
		value_label.text = str(roundi(current_value))
	var progress_bar_red := %ProgressBarRed as ProgressBar
	var progress_bar_yellow := %ProgressBarYellow as ProgressBar
	progress_bar_red.max_value = max_value
	progress_bar_yellow.max_value = max_value
	progress_bar_red.value = current_value
	progress_bar_yellow.value = maxf(unit.get_attack_speed(), 0) if is_speed else current_value
	var resize_handler := $ResizeHandler as ReferenceRect
	resize_handler.set_size.call_deferred(
		Vector2(size.x * (float(max_value) / ABSOLUTE_MAX_VALUE), resize_handler.size.y)
	)

	help_table = unit.get_stat_table(stat)
	table_columns = 4
