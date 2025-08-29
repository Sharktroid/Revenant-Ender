@tool
class_name MountedUnit
extends UnitClass


# Unit class-specific variables.
func _init() -> void:
	_aid_modifier = 25
	_skills.append(Canter.new())
	_skills = _skills.filter(func(skill: Skill) -> bool: return skill is not Shove)
	_armor_classes |= ArmorClasses.CAVALRY
	super()
