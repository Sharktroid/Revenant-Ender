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


func _load_preset(old_preset: _Presets, new_preset: _Presets) -> void:
	super(old_preset, new_preset)


func _load_heavy_modifiers() -> void:
	super()
	# Reverting the heavy modifiers
	var heavy_multiplier: int = 1 if _heavy_weapon else -1
	_weight -= (_HEAVY_WEIGHT_MODIFIER * heavy_multiplier) * 0.5
	_hit -= (_HEAVY_HIT_MODIFIER * heavy_multiplier)
	_max_range = 1


func _update_linked_weapon() -> void:
	if _heavy_weapon:
		_mode_name = ""
		_linked_weapon = null
	else:
		_mode_name = "Melee"
		_linked_weapon = _clone()
		_linked_weapon._damage_type = DamageTypes.RANGED
		_linked_weapon._mode_name = "Throw"
		_linked_weapon._max_range = 2
