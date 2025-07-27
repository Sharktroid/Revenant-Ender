class_name Kingmaker
extends Sword


func _init() -> void:
	resource_name = "Aertherea"
	_rank = Ranks.D
	_max_uses = 60
	_price = 43
	_might += 9
	_weight += 6
	_hit += 95
	_crit = 25
	# TODO: Give a non-placeholder name for Rashi's brother.
	_flavor_text = '"King-maker." A jewel-studded sword coated in a thin layer of gold.\n'
	_description = "+1 c. s. strike. Grants charisma and charm. Rashi's brother only."
	super()
