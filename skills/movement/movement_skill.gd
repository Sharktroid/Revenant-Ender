@abstract class_name MovementSkill
extends Skill

## The number of tiles the unit moves forwards during the action.
var _self_move: int
## The number of tiles the target moves forwards during the action.
var _target_move: int


func get_self_move() -> int:
	return _self_move


func get_target_move() -> int:
	return _target_move


func is_move_valid(target_unit: Unit, moving_unit: Unit, destination_tile: Vector2) -> bool:
	var distance: Vector2 = target_unit.position - destination_tile
	var moving_unit_valid_tiles: Set = moving_unit.get_actionable_movement_tiles()
	moving_unit_valid_tiles.append(Vector2i(target_unit.position))
	var target_unit_valid_tiles: Set = target_unit.get_actionable_movement_tiles()
	target_unit_valid_tiles.append(Vector2i(destination_tile))
	if moving_unit_valid_tiles.has(Vector2i(destination_tile + distance * get_self_move())):
		return target_unit_valid_tiles.has(
			Vector2i(target_unit.position + distance * get_target_move())
		)
	else:
		return false
