class_name Volganone
extends Anima


func _init() -> void:
	const INTELLIGENCE_MODIFIER: int = 5
	_heavy_weapon = true
	resource_name = "Volganone"
	_rank = Ranks.D
	_max_uses = 20
	_price = 51
	_might += 14 - INTELLIGENCE_MODIFIER
	_weight += 3
	_hit -= 5
	_flavor_text = "Causes a burst of magma to erupt from within the planet, and incinerate foes."
	_description = "+%d int."
	super()