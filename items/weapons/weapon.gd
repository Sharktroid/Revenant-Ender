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
enum Ranks {
	S = 251,
	A = 181,
	B = 121,
	C = 71,
	D = 31,
	E = 1,
	DISABLED = 0
}
enum DamageTypes {
	PHYSICAL,
	RANGED,
	MAGIC
}

var level: int
var might: int
var weight: int
var hit: int
var crit: int
var min_range: int
var max_range: int
var weapon_exp: int
var effective_classes: int
var type: Types
var advantage_types: Array[Types]
var disadvantage_types: Array[Types]

var _damage_type: DamageTypes
var _damage_type_ranged: DamageTypes

func _init() -> void:
	if not _damage_type:
		match type:
			Types.SWORD, Types.AXE, Types.KNIFE, Types.SPEAR: _damage_type = DamageTypes.PHYSICAL
			Types.BOW: _damage_type = DamageTypes.RANGED
			Types.COBALT_STAFF, Types.CRIMSON_STAFF, Types.LIGHT, Types.DARK, \
			Types.ANIMA: _damage_type = DamageTypes.MAGIC
	if not _damage_type_ranged:
		_damage_type_ranged = _damage_type
	super()


func get_damage_type() -> DamageTypes:
	return _damage_type


func get_range() -> Array:
	return range(min_range, max_range + 1)


func get_stat_table() -> Array[String]:
	return Utilities.dict_to_table.call({
		str(Types.find_key(type)).capitalize(): str(Ranks.find_key(level)).capitalize(),
		"Range": str(min_range) if min_range == max_range else "%d-%d" % [min_range, max_range],
		"Weight": weight,
		"Might": might,
		"Hit": hit,
		"Critical": crit
	})


## Returns 1 with normal advantage, 0 with neutrality, -1 with disadvantage
func get_weapon_triangle_advantage(weapon: Weapon, _distance: int) -> int:
	return (
			1 if weapon.type in advantage_types
			else -1 if weapon.type in disadvantage_types
			else 0
	)


func get_hit_bonus(weapon: Weapon, distance: int) -> int:
	if weapon is Bow:
		return -10 * weapon.get_weapon_triangle_advantage(self, distance)
	else:
		var bonus: int = 10 if level >= Ranks.B else 5 if level >= Ranks.D else 0
		return bonus * get_weapon_triangle_advantage(weapon, distance)


func get_damage_bonus(weapon: Weapon, distance: int) -> int:
	if weapon is Bow:
		return -weapon.get_weapon_triangle_advantage(self, distance)
	else:
		return get_weapon_triangle_advantage(weapon, distance) if level >= Ranks.S else 0
