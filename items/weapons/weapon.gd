class_name Weapon
extends Item

enum types {
	SWORD,
	SPEAR,
	AXE,
	BOW,
	KNIFE,
	ANIMA,
	LIGHT,
	DARK,
	CRIMSON_STAFF,
	COBALT_STAFF,
	SIEGE,
	CLAW,
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
var weapon_experience: int
var effective_classes: int
var type: types
var _damage_type: damage_types
var _damage_type_ranged: damage_types

func _init() -> void:
	if not _damage_type:
		match type:
			types.SWORD, types.AXE, types.KNIFE, types.SPEAR: _damage_type = damage_types.PHYSICAL
			types.BOW: _damage_type = damage_types.RANGED
			types.COBALT_STAFF, types.CRIMSON_STAFF, types.LIGHT, types.DARK, \
			types.ANIMA: _damage_type = damage_types.MAGIC
	if not _damage_type_ranged:
		_damage_type_ranged = _damage_type
	super()


func get_damage_type() -> damage_types:
	return _damage_type


func get_range() -> Array:
	return range(min_range, max_range + 1)


func get_description() -> String:
	var get_range_string: Callable = func() -> String:
		if min_range == max_range:
			return str(min_range)
		else:
			return "%d-%d" % [min_range, max_range]

	var weapon_stats: Dictionary = {
		str(types.find_key(type)).capitalize(): str(ranks.find_key(level)).capitalize(),
		"Range": get_range_string.call(),
		"Weight": weight,
		"Might": might,
		"Hit\t": hit,
		"Critical": crit
	}
	return Utilities.dict_to_table.call(weapon_stats, 3) + "\n" + _description
