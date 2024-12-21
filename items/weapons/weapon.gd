class_name Weapon
extends Item

enum Types {
	SWORD,
	SPEAR,
	AXE,
	BOW,
	KNIFE,
	ANIMA,
	HOLY,
	ELDRITCH,
	CRIMSON_STAFF,
	COBALT_STAFF,
	SIEGE,
	SHIELD,
}
enum Ranks { S = 181, A = 121, B = 71, C = 31, D = 1, DISABLED = 0 }
enum DamageTypes { PHYSICAL, RANGED, MAGICAL }
enum AdvantageState { ADVANTAGE = 1, DISADVANTAGE = -1, NEUTRAL = 0 }

var _rank: int
var _might: float
var _weight: float
var _hit: float
var _crit: float
var _min_range: int
var _max_range: float
var _weapon_exp: int
var _effective_classes: int
var _type: Types
var _advantage_types: Array[Types]
var _disadvantage_types: Array[Types]
var _damage_type: DamageTypes
var _damage_type_ranged: DamageTypes


func _init() -> void:
	if not _damage_type:
		match _type:
			Types.SWORD, Types.AXE, Types.KNIFE, Types.SPEAR:
				_damage_type = DamageTypes.PHYSICAL
			Types.BOW:
				_damage_type = DamageTypes.RANGED
			Types.COBALT_STAFF, Types.CRIMSON_STAFF, Types.HOLY, Types.ELDRITCH, Types.ANIMA:
				_damage_type = DamageTypes.MAGICAL
	if not _damage_type_ranged:
		_damage_type_ranged = _damage_type
	super()


func get_damage_type() -> DamageTypes:
	return _damage_type


func in_range(distance: int) -> bool:
	return distance <= get_max_range() and distance >= get_min_range()


func get_stat_table() -> Array[String]:
	var table: Dictionary = {
		str(Types.find_key(_type)).capitalize(): str(Ranks.find_key(_rank)).capitalize(),
		"Range": get_range_text(),
		"Weight": Utilities.float_to_string(_weight),
		"Might": Utilities.float_to_string(_might),
		"Hit": Utilities.float_to_string(_hit),
		"Critical": Utilities.float_to_string(_crit)
	}
	return Utilities.dict_to_table(table)


func get_weapon_triangle_advantage(weapon: Weapon, _distance: int) -> AdvantageState:
	if weapon:
		if weapon.get_type() in _advantage_types:
			return AdvantageState.ADVANTAGE
		elif weapon.get_type() in _disadvantage_types:
			return AdvantageState.DISADVANTAGE
		else:
			return AdvantageState.NEUTRAL
	else:
		return AdvantageState.NEUTRAL


func get_hit_bonus(weapon: Weapon, distance: int) -> int:
	if weapon is Bow:
		return -10 * weapon.get_weapon_triangle_advantage(self, distance)
	else:
		var bonus: int = 5 if _rank >= Ranks.C else 0
		return bonus * get_weapon_triangle_advantage(weapon, distance)


func get_damage_bonus(weapon: Weapon, distance: int) -> int:
	if weapon is Bow:
		return -weapon.get_weapon_triangle_advantage(self, distance)
	else:
		return get_weapon_triangle_advantage(weapon, distance) if _rank >= Ranks.A else 0


func get_rank() -> int:
	return _rank


func get_might() -> float:
	return roundf(_might)


func get_weight() -> float:
	return roundf(_weight)


func get_hit() -> float:
	return _hit


func get_crit() -> float:
	return roundf(_crit)


func get_min_range() -> int:
	return _min_range


func get_max_range() -> float:
	return _max_range


func get_weapon_exp() -> int:
	return _weapon_exp


func get_effective_classes() -> int:
	return _effective_classes


func get_type() -> Types:
	return _type


func get_advantage_types() -> Array[Types]:
	return _advantage_types


func get_disadvantage_types() -> Array[Types]:
	return _disadvantage_types


func get_range_text() -> String:
	var max_range_text: String = Utilities.float_to_string(get_max_range())
	if _min_range == get_max_range():
		return max_range_text
	else:
		return "{min}-{max}".format({"min": str(get_min_range()), "max": max_range_text})
