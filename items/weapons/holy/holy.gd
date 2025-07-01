class_name Holy
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.HOLY
	_min_range = 1
	_max_range = 2
	_advantage_types = [Types.ELDRITCH]
	_disadvantage_types = [Types.ANIMA]
	_might = 2
	_hit = 105
	_weight = 3
	_crit = 5
	_damage_type = DamageTypes.MAGICAL
	super()
