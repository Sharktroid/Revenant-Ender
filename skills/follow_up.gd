class_name FollowUp
extends Skill


func can_follow_up(unit: Unit, opponent: Unit) -> bool:
	return unit.get_attack_speed() - opponent.get_attack_speed() >= 4
