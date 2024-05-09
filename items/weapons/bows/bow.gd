class_name Bow
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.BOW
	_min_range = 2
	_max_range = 2
	super()


func get_weapon_triangle_advantage(weapon: Weapon, distance: int) -> int:
	return 0 if weapon.get_type() == Types.BOW else -1 if distance == 1 else 1


func get_hit_bonus(weapon: Weapon, distance: int) -> int:
	return 10 * get_weapon_triangle_advantage(weapon, distance)


func get_damage_bonus(weapon: Weapon, distance: int) -> int:
	return get_weapon_triangle_advantage(weapon, distance)
