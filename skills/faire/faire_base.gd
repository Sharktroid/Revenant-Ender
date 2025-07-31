class_name Faire
extends Skill

enum Variants { ALPHA, BETA, GAMMA, DELTA }

@export var weapon_type: Weapon.Types
@export var variant: Variants


func _init(_weapon_type := Weapon.Types.SWORD, _variant := Variants.ALPHA) -> void:
	weapon_type = weapon_type
	variant = variant


func get_rank_boost() -> int:
	match variant:
		Variants.ALPHA:
			return 1
		Variants.BETA:
			return 2
		Variants.GAMMA:
			return 3
		Variants.DELTA:
			return 4
		_:
			return 0


func get_weapon_type() -> Weapon.Types:
	return weapon_type
