class_name DevilAxe
extends Axe


func _init() -> void:
	resource_name = "Devil Axe"
	_rank = Ranks.D
	_max_uses = 66
	_price = 13
	_might += 17
	_hit += 25
	_crit = 25
	_flavor_text = "A cursed axe will sometimes backfire on its wielder."
	_description = "Has a (15 - luck + enemy's luck)% chance of backfiring."
	super()