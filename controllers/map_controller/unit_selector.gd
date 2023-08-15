class_name UnitSelector
extends Control

signal selected(unit: Unit)
signal canceled

var unit: Unit

func _init(connected_unit: Unit) -> void:
	unit = connected_unit
	name = "Unit Selector"


func _ready() -> void:
	GenVars.cursor.enable()
	unit.hide_movement_tiles()
	unit.display_current_attack_tiles(unit.get_unit_path()[-1])
	unit.remove_path()
	set_focus_mode(Control.FOCUS_ALL)
	grab_focus()


func _process(_delta: float) -> void:
	if (GenVars.cursor as Cursor).get_hovered_unit() == null:
		(GenVars.cursor as Cursor).remove_icon()
	else:
		(GenVars.cursor as Cursor).draw_icon(Cursor.icons.ATTACK)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_position_selected()
	elif event.is_action_pressed("ui_cancel"):
		_canceled()


func _has_point(_point: Vector2) -> bool:
	return true


func close() -> void:
	unit.hide_current_attack_tiles()
	unit.set_animation(unit.animations.IDLE)
	(GenVars.cursor as Cursor).remove_icon()
	queue_free()


func _position_selected() -> void:
	if GenVars.cursor.get_hovered_unit() != null:
		emit_signal("selected", GenVars.cursor.get_hovered_unit())
		close()


func _canceled() -> void:
	emit_signal("selected", null)
	GenVars.cursor.disable()
	unit.display_movement_tiles()
	unit.show_path()
	close()
