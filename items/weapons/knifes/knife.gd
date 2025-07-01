class_name Knife
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_min_range = 1
	_max_range = 2
	_type = Types.KNIFE
	_might = 4
	_hit = 105
	_weight = 4
	super()

func _load_heavy_modifiers() -> void:
	super()
	# Reverting the heavy modifiers
	var heavy_multiplier: int = 1 if _heavy_weapon else -1
	_weight -= (_HEAVY_WEIGHT_MODIFIER * heavy_multiplier) * 0.5
	_hit -= (_HEAVY_HIT_MODIFIER * heavy_multiplier)

	_max_range = 1
