#tool
extends "res://Unit Classes/city.gd"


func _init():
	add_skill("Produces", ["Infantry"])
	unit_class = "Factory"
	selectable = true
	_starting_frame = 6


func _update_sprite() -> void:
	super._update_sprite()
	var frame_num: int = int(GenVars.get_tick_timer()) % 80
	$Smoke.frame = 280 + floor(frame_num/20.0)
