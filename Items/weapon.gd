class_name Weapon
extends Item

enum types {
	SWORD,
	LANCE,
	AXE,
	BOW,
	KNIFE,
	WIND,
	FIRE,
	LIGHTNING,
	LIGHT,
	DARK,
	CRIMSON_STAFF,
	COBALT_STAFF,
}
enum ranks {
	S = 251,
	A = 181,
	B = 121,
	C = 71,
	D = 31,
	E = 1,
	DISABLED = 0
}
enum damage_types {
	PHYSICAL,
	RANGED,
	MAGIC
}

var level: ranks
var might: int
var weight: int
var hit: int
var crit: int
var min_range: int
var max_range: int
var max_durability: int
var current_durability: int
var price: int
var weapon_experience: int
var effective_classes: int
var type: types
var _damage_type: damage_types
var _damage_type_ranged

func _init() -> void:
	if not _damage_type:
		match type:
			types.SWORD, types.AXE, types.KNIFE, types.LANCE: _damage_type = damage_types.PHYSICAL
			types.BOW: _damage_type = damage_types.RANGED
			types.COBALT_STAFF, types.CRIMSON_STAFF, types.LIGHT, types.DARK, \
			types.FIRE, types.WIND, types.LIGHTNING: _damage_type = damage_types.PHYSICAL
	if not _damage_type_ranged:
		_damage_type_ranged = _damage_type


func get_damage_type() -> damage_types:
	return _damage_type
