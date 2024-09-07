class_name Rapier
extends Sword


func _init() -> void:
	resource_name = "Rapier"
	_rank = Ranks.C
	_might = 5
	_weight = 3
	_hit = 110
	_crit = 10
	_max_uses = 30
	_price = 6000
	_weapon_exp = 2
	_description = "A thin, nimble sword.\nx1.5 bonus damage against cavalry and armored units"
#	effective_classes
	super()
