class_name Pascanion
extends Bow


func _init() -> void:
	super()
	resource_name = "Pascanion"
	_rank = Ranks.D
	_max_uses = 40
	_price = 13
	_might += 5
	_flavor_text = "A fire-enchanted bow that envelops both battlers into a second round of combat."
	_description = "+10 magic damage. x2 rounds of combat."
