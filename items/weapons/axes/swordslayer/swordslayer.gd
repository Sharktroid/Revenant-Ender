class_name Swordslayer
extends Axe


func _init() -> void:
	_preset = _Presets.REAVER
	resource_name = "Swordslayer"
	_rank = Ranks.A
	_flavor_text = "An axe designed to slay swordsmen."
	_description += " Effective against sword-wielding enemies."
	super()