class_name ToxinSpear
extends Spear


func _init() -> void:
	_preset = _Presets.STATUS
	_rank = Ranks.B
	_flavor_text = "A spear with a toxin-coated tip, designed to inflict poison on its targets."
	_description = "Inflicts poison on hit."
	super()