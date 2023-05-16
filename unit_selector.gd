class_name UnitSelector
extends Node

signal selected(unit: Unit)

var unit: Unit

func _init(connected_unit: Unit) -> void:
	unit = connected_unit


func _on_cursor_select() -> void:
	var true_cursor_pos: Vector2i = GenVars.get_cursor().get_true_pos()
	if true_cursor_pos in unit.get_current_attack_tiles(unit.get_unit_path()[-1]) \
			and GenVars.get_level_controller().is_cursor_over_hovered_unit():
		emit_signal("selected", GenVars.get_level_controller().hovered_unit)
