class_name RadiantBow
extends Bow


func _init() -> void:
	resource_name = "Radiant Bow"
	_rank = Ranks.B
	_max_uses = 30
	_price = 36
	_might += 5
	_weight += 2
	_hit -= 5
	_damage_type = DamageTypes.MAGICAL
	_flavor_text = "A bow empowered with light magic, letting it cast holy spells."
	super()
