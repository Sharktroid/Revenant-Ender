extends "res://Unit Classes/base_aw.gd"


func _init():
	selectable = false
	_max_health = 20
	tags += [all_tags.BUILDING, all_tags.NOBLOCK]
	_starting_frame = 5
	_faction_dict = {"Red": 0, "Blue": 40, "Yellow": 80, "Green": 120,
		"Black": 160, "Neutral": 200}
	unit_class = "City"


func _update_sprite() -> void:
	super._update_sprite()
	var frame_num: int = int(GenVars.get_tick_timer()) % 64
#	if frame_num >= 48 and GenVars.map.get_unit_faction(faction).color != "Neutral":
#		frame += 20
