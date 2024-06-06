extends "res://units/unit_classes/advance_wars/aw_unit.gd"


# func _init() -> void:
	# _starting_frame = 0
#	movement_type = "Infantry"
#	tags.append("Infantry")
	# _faction_dict = {"Red": 0, "Blue": 15, "Green": 810, "Yellow": 825,
	# 	"Black": 1620}
	# _variant_dict = {"Orange Star": 0, "Blue Moon": 30, "Green Earth": 60,
	# 	"Yellow Comet": 90, "Black Hole": 120}
#	unit_class = "Infantry"


func wait() -> void:
	if Utilities.get_debug_value(Utilities.DebugConfigKeys.UNIT_WAIT):
		_base_frame += 3
#	_update_sprite()
	super.wait()


func awaken() -> void:
	if selectable == false:
		_base_frame -=3
#		_update_sprite()
	super.awaken()


#func _update_sprite() -> void:
#	super.get_update_sprite()()
#	if map_animation == Animations.IDLE:
#		var frame_num: int = int(get_tree().get_frame()) % 50
#		if (frame_num >= 17 and frame_num < 25) or frame_num >= 42:
#			frame += 1
#		elif frame_num >= 25 and frame_num < 42:
#			frame += 2
#	else:
#		match map_animation:
#			Animations.MOVING_RIGHT, Animations.MOVING_LEFT: frame += 6
#			Animations.MOVING_DOWN: frame += 9
#			Animations.MOVING_UP: frame += 12
#		var frame_num: int = int(get_tree().get_frame()) % 26
#		if (frame_num >= 8 and frame_num < 13) or frame_num >= 21:
#			frame += 1
#		elif frame_num >= 13 and frame_num < 21:
#			frame += 2
#	if map_animation == Animations.MOVING_LEFT:
#		flip_h = true
#	else:
#		flip_h = false
