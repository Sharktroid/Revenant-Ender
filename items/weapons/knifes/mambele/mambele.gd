class_name Mambele
extends Knife
# A Knife with Axe stats


func _init() -> void:
	super()
	resource_name = "Mambele"
	_rank = Ranks.B
	_max_uses = 30
	_price = 31
	var base_axe := Axe.new()
	_might = base_axe.get_might() + 7
	_weight = base_axe.get_weight()
	_hit = base_axe.get_hit()
	_max_range = 2
	_flavor_text = "A hybrid of an axe and a knife, featuring multiple blades designed to inflict damage no matter what side lands on an opponent."