class_name UnitSelector
extends Node

signal selected(unit: Unit)
signal canceled

var unit: Unit

func _init(connected_unit: Unit) -> void:
	unit = connected_unit


func _ready() -> void:
	GenVars.get_cursor().set_active(true)
	GenVars.get_cursor().connect_to(self)
	unit.hide_movement_tiles()
	unit.display_current_attack_tiles(unit.get_unit_path()[-1])
	unit.remove_path()


func close() -> void:
	unit.hide_current_attack_tiles()
	unit.map_animation = unit.animations.IDLE
	queue_free()


func _on_cursor_select() -> void:
	var true_cursor_pos: Vector2i = GenVars.get_cursor().get_true_pos()
	if GenVars.get_cursor().get_hovered_unit() != null:
		emit_signal("selected", GenVars.get_cursor().get_hovered_unit())
		close()


func _on_cursor_cancel() -> void:
	emit_signal("selected", null)
	GenVars.get_cursor().set_active(false)
	unit.display_movement_tiles()
	unit.show_path()
	close()
