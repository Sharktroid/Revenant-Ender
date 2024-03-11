extends HBoxContainer

const V_MOD: int = 32

var attacker: Unit
var defender: Unit


func _enter_tree() -> void:
	($"Left HP Bar" as MapHPBar).unit = attacker
	($"Right HP Bar" as MapHPBar).unit = defender
	position = (Vector2((attacker.position.x + defender.position.x)/2 - size.x/2,
			maxf(attacker.position.y, defender.position.y))
			- Vector2(MapController.get_map_camera().map_position)
			+ Vector2(MapController.get_map_camera().get_map_offset()) + Vector2(8, V_MOD))
	if position.y + size.y > Utilities.get_screen_size().y:
		position.y -= (size.y + V_MOD * 2)
