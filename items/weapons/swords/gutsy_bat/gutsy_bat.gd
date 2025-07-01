class_name GutsyBat
extends Sword


func _init() -> void:
	super()
	resource_name = "Gutsy Bat"
	_rank = Ranks.A
	_max_uses = 60
	_price = 43
	_might += 12
	_hit = 94
	_crit = 45
	_flavor_text = "An aluminum baseball bat with a handle made of kraken skin. Fills the wielder with courage."
	_description = "+15 luck"
