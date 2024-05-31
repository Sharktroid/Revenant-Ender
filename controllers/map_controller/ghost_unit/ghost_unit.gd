class_name GhostUnit
extends Node2D

var _unit: Unit


func _init(connected_unit: Unit) -> void:
	_unit = connected_unit.duplicate() as Unit
	z_index = 1
	_unit.position = Vector2i()
	_unit.get_node("Area2D").queue_free()
	_unit.get_node("HealthBar").queue_free()
	_unit.get_node("Status").queue_free()
	_unit.remove_from_group("unit")
	_unit.modulate.a = 0.5
	add_child(_unit)


func _exit_tree() -> void:
	await _unit.tree_exited


func set_animation(new_animation: Unit.Animations) -> void:
	_unit.set_animation(new_animation)
