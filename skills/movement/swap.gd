class_name Swap
extends MovementSkill


func _init() -> void:
	_self_move = 1
	_target_move = -1
	_name = "Swap"


func is_move_valid(target_unit: Unit, moving_unit: Unit, destination_tile: Vector2) -> bool:
	return moving_unit.is_friend(target_unit) and super(target_unit, moving_unit, destination_tile)
