class_name Bow
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.BOW
	_min_range = 2
	_max_range = 3
	super()


func get_weapon_triangle_advantage(weapon: Weapon, distance: int) -> AdvantageState:
	if weapon.get_type() == Types.BOW:
		return AdvantageState.NEUTRAL
	else:
		return AdvantageState.DISADVANTAGE if distance == 1 else AdvantageState.ADVANTAGE


func get_hit_bonus(weapon: Weapon, distance: int) -> int:
	return 10 * get_weapon_triangle_advantage(weapon, distance)


func get_damage_bonus(weapon: Weapon, distance: int) -> int:
	return get_weapon_triangle_advantage(weapon, distance)
