class_name Anima
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.ANIMA
	_min_range = 1
	_max_range = 2
	_advantage_types |= 1 << Types.HOLY
	_disadvantage_types |= 1 << Types.ELDRITCH
	_might += 4
	_hit += 100
	_weight += 4
	_damage_type = DamageTypes.MAGICAL
	super()
