class_name MainGauche
extends Knife


func _init() -> void:
	super()
	resource_name = "Main-Gauche"
	_rank = Ranks.C
	_max_uses = 45
	_price = 26
	_hit -= 10
	_flavor_text = "A dagger with a wide hilt, grip, and guard and a long blade to assist in parrying."
	_description = "+5 defense."