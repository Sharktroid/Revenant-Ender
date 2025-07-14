@tool
class_name StatBar
extends HelpContainer

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: int = ceili(30 + (Unit.PV_MAX_MODIFIER) + (Unit.EV_MAX_MODIFIER))

## The stat being displayed
@export var stat: Unit.Stats
## The unit whose stat is displayed
var unit: Unit:
	set(value):
		unit = value
		_update()

#func _ready() -> void:
#visibility_changed.connect(_update)


static func instantiate(new_stat: Unit.Stats) -> StatBar:
	const PACKED_SCENE: PackedScene = preload(
		"res://ui/map_ui/status_screen/statistics/stat_bar/stat_bar.tscn"
	)
	var scene := PACKED_SCENE.instantiate() as StatBar
	scene.stat = new_stat
	return scene


func _update() -> void:
	var max_value: float = maxi(unit.get_stat_cap(stat), 10)
	var numeric_progress_bar := $NumericProgressBar as NumericProgressBar
	numeric_progress_bar.mode = NumericProgressBar.Modes.INTEGER

	numeric_progress_bar.max_value = max_value
	if stat == Unit.Stats.SPEED:
		numeric_progress_bar.value = unit.get_attack_speed()
	else:
		numeric_progress_bar.value = unit.get_stat(stat)
	numeric_progress_bar.original_value = unit.get_raw_stat(stat)
	numeric_progress_bar.custom_minimum_size = (Vector2(
		size.x * (float(max_value) / ABSOLUTE_MAX_VALUE), numeric_progress_bar.size.y
	))

	help_table = unit.get_stat_table(stat)
