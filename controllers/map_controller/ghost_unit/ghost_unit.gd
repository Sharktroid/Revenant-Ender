class_name GhostUnit
extends Node2D

var _unit: Unit


func _init(connected_unit: Unit) -> void:
	_unit = connected_unit.duplicate()
	z_index = 1


func _ready() -> void:
	_unit.position = Vector2i()
	_unit.get_node("Area2D").queue_free()
	_unit.get_node("Health Bar").queue_free()
	_unit.get_node("Status").queue_free()
	_unit.remove_from_group("unit")
	_unit.modulate.a = 0.5
	add_child(_unit)


func set_animation(new_animation: Unit.animations) -> void:
	_unit.set_animation(new_animation)
