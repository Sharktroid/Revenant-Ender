extends "res://Unit Classes/base_aw.gd"


func _init():
	super._init()
	_starting_frame = 0
	movement_type = "Infantry"
	_attack_range = 1
	tags.append("Infantry")
	_faction_dict = {"Red": 0, "Blue": 15, "Green": 810, "Yellow": 825,
		"Black": 1620}
	_variant_dict = {"Orange Star": 0, "Blue Moon": 30, "Green Earth": 60,
		"Yellow Comet": 90, "Black Hole": 120}
	unit_class = "Infantry"


func wait() -> void:
	if GenVars.get_debug_constant("unit_wait"):
		_base_frame += 3
	_update_sprite()
	super.wait()


func awaken() -> void:
	if selectable == false:
		_base_frame -=3
		_update_sprite()
	super.awaken()


func _update_sprite() -> void:
	super._update_sprite()
	if map_animation == "Idle":
		var frame_num: int = int(GenVars.get_tick_timer()) % 50
		if (frame_num >= 17 and frame_num < 25) or frame_num >= 42:
			frame += 1
		elif frame_num >= 25 and frame_num < 42:
			frame += 2
	else:
		match map_animation:
			"Walking_Right", "Walking_Left": frame += 6
			"Walking_Down": frame += 9
			"Walking_Up": frame += 12
		var frame_num: int = int(GenVars.get_tick_timer()) % 26
		if (frame_num >= 8 and frame_num < 13) or frame_num >= 21:
			frame += 1
		elif frame_num >= 13 and frame_num < 21:
			frame += 2
	if map_animation == "Walking_Left":
		flip_h = true
	else:
		flip_h = false
