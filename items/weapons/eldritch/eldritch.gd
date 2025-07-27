class_name Eldritch
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_heavy_weapon = true
	_type = Types.HOLY
	_min_range = 1
	_max_range = 2
	_advantage_types = [Types.ANIMA]
	_disadvantage_types = [Types.HOLY]
	_might += 7
	_hit += 85
	_weight += 6
	_damage_type = DamageTypes.MAGICAL
	super()
