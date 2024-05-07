class_name Bow
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = Types.BOW
	min_range = 2
	max_range = 2
	super()


func get_weapon_triangle_advantage(weapon: Weapon, distance: int) -> int:
	return 0 if weapon.type == Types.BOW else -1 if distance == 1 else 1


func get_hit_bonus(weapon: Weapon, distance: int) -> int:
	return 10 * get_weapon_triangle_advantage(weapon, distance)


func get_damage_bonus(weapon: Weapon, distance: int) -> int:
	return get_weapon_triangle_advantage(weapon, distance)
