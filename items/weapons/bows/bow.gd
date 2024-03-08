class_name Bow
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = types.BOW
	min_range = 2
	max_range = 2
	super()


func get_weapon_triangle_advantage(weapon: Weapon, distance: int) -> int:
	if weapon.type == types.BOW:
		return 0
	else:
		if distance == 1:
			return -1
		else:
			return 1


func get_hit_bonus(weapon: Weapon, distance: int) -> int:
	return 10 * get_weapon_triangle_advantage(weapon, distance)


func get_damage_bonus(weapon: Weapon, distance: int) -> int:
	return get_weapon_triangle_advantage(weapon, distance)
