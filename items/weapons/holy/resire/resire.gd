class_name Resire
extends Holy


func _init() -> void:
	_heavy_weapon = true
	resource_name = "Resire"
	_rank = Ranks.A
	_max_uses = 16
	_price = 46
	_might += 5
	_weight += 2
	_hit += 5
	_max_range += 1
	_recoil_multiplier = -0.5
	_flavor_text = "Rends the foe with a piercing life that drains their energy and uses it to replenish the wielder."
	_description = "Grants Wary Fighter. Restores 1 HP per 2 dealt."
	super()
