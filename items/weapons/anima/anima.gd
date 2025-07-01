class_name Anima
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.ANIMA
	_min_range = 1
	_max_range = 2
	_advantage_types = [Types.HOLY]
	_disadvantage_types = [Types.ELDRITCH]
	_might = 4
	_hit = 100
	_weight = 4
	_damage_type = DamageTypes.MAGICAL
	super()
