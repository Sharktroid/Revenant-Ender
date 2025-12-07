class_name Shove
extends MovementSkill


func _init() -> void:
	_target_move = 1
	_name = "Shove"


func is_move_valid(target_unit: Unit, moving_unit: Unit, destination_tile: Vector2) -> bool:
	return (
		super(target_unit, moving_unit, destination_tile)
		and target_unit.get_weight() < moving_unit.get_build()
	)
