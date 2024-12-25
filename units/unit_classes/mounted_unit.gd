@tool
class_name MountedUnit
extends UnitClass


# Unit class-specific variables.
func _init() -> void:
	_aid_modifier = 25
	_skills.append(Canter.new())
	super()
