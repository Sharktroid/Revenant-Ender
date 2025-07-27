class_name Mookscalibur
extends Anima


func _init() -> void:
	_preset = _Presets.MEME
	resource_name = "Mookscalibur"
	_rank = Ranks.D
	_max_uses = 15
	_price = 1
	_might -= 3
	_flavor_text = 'It still has a sticker saying "For Sale! Grate bargan!" on it.'
	super()