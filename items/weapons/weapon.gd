class_name Weapon
extends Item

enum Types {
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
enum Ranks { S = 181, A = 121, B = 71, C = 31, D = 1, DISABLED = 0 }
enum DamageTypes { PHYSICAL, RANGED, INTELLIGENCE }

var _rank: int
var _might: int
var _weight: int
var _hit: int
var _crit: int
var _min_range: int
var _max_range: int
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
			Types.COBALT_STAFF, Types.CRIMSON_STAFF, Types.LIGHT, Types.DARK, Types.ANIMA:
				_damage_type = DamageTypes.INTELLIGENCE
	if not _damage_type_ranged:
		_damage_type_ranged = _damage_type
	super()


func get_damage_type() -> DamageTypes:
	return _damage_type


func get_range() -> Array:
	return range(_min_range, _max_range + 1)


func get_stat_table() -> Array[String]:
	return Utilities.dict_to_table.call(
		{
			str(Types.find_key(_type)).capitalize(): str(Ranks.find_key(_rank)).capitalize(),
			"Range":
			str(_min_range) if _min_range == _max_range else "%d-%d" % [_min_range, _max_range],
			"Weight": _weight,
			"Might": _might,
			"Hit": _hit,
			"Critical": _crit
		}
	)


## Returns 1 with normal advantage, 0 with neutrality, -1 with disadvantage
func get_weapon_triangle_advantage(weapon: Weapon, _distance: int) -> int:
	return (
		0 if weapon == null
		else 1 if weapon.get_type() in _advantage_types
		else -1 if weapon.get_type() in _disadvantage_types
		else 0
	)


func get_hit_bonus(weapon: Weapon, distance: int) -> int:
	if weapon is Bow:
		return -10 * weapon.get_weapon_triangle_advantage(self, distance)
	var bonus: int = 5 if _rank >= Ranks.C else 0
	return bonus * get_weapon_triangle_advantage(weapon, distance)


func get_damage_bonus(weapon: Weapon, distance: int) -> int:
	return (
		-weapon.get_weapon_triangle_advantage(self, distance) if weapon is Bow
		else get_weapon_triangle_advantage(weapon, distance) if _rank >= Ranks.A
		else 0
	)


func get_rank() -> int:
	return _rank


func get_might() -> int:
	return _might


func get_weight() -> int:
	return _weight


func get_hit() -> int:
	return _hit


func get_crit() -> int:
	return _crit


func get_min_range() -> int:
	return _min_range


func get_max_range() -> int:
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
