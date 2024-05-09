class_name Rapier
extends Sword

func _init() -> void:
	resource_name = "Rapier"
	_rank = Ranks.C
	_might = 7
	_weight = 5
	_hit = 95
	_crit = 10
	_max_uses = 40
	_price = 6000
	_weapon_exp = 2
	_description = "A thin, nimble sword.\nx1.5 bonus damage against cavalry and armored units"
#	effective_classes
	super()
