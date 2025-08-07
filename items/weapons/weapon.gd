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
enum Ranks { S = 5, A = 4, B = 3, C = 2, D = 1, DISABLED = 0 }
enum DamageTypes { PHYSICAL, RANGED, MAGICAL }
enum AdvantageState { ADVANTAGE = 1, DISADVANTAGE = -1, NEUTRAL = 0 }

enum _Presets {
	NONE,
	IRON,
	SLIM,
	MEME,
	TRAINING,
	BRONZE,
	ANTI_MONSTER,
	STEEL,
	KILLER,
	REAVER,
	SILVER,
	BRAVE,
	STATUS,
	MASTER,
	DIAMOND
}

const _RANK_SCALING_MIGHT: int = 4
const _HEAVY_PRICE_MODIFIER: int = 5
const _HEAVY_HIT_MODIFIER: int = -10
const _HEAVY_MIGHT_MODIFIER: int = 8
const _HEAVY_WEIGHT_MODIFIER: int = 6
const _HEAVY_DURABILITY_MODIFIER: int = 10

var _rank: Ranks = Ranks.DISABLED
var _might: float
var _weight: float
var _hit: float
var _crit: float = 0
var _min_range: int
var _max_range: float
var _weapon_exp: int
var _effective_classes: int
var _type: Types
var _advantage_types: int
var _disadvantage_types: int
var _damage_type: DamageTypes
var _damage_type_ranged: DamageTypes
var _preset: _Presets:
	set(value):
		_load_preset(_preset, value)
		_preset = value
var _heavy_weapon: bool = false:
	set(value):
		_heavy_weapon = value
		_load_heavy_modifiers()
var _mode_name: String
var _linked_weapon: Weapon = null:
	set(value):
		_linked_weapon = value
		_linked_weapon.resource_name = resource_name
		_linked_weapon._flavor_text = _flavor_text
		_linked_weapon._rank = _rank
		_linked_weapon._type = _type
		_linked_weapon._price = _price
		_linked_weapon._icon = _icon


func _init() -> void:
	if resource_name == "":
		_update_name()
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


func get_stat_table() -> Table:
	var table: Dictionary[String, String] = {
		"Mode": _mode_name if _mode_name.length() > 0 else "Standard",
		"Type": (Types.find_key(_type) as String).capitalize(),
		"G/use": Utilities.float_to_string(_price, true),
		"Might": Utilities.float_to_string(_might, true),
		"Hit": Utilities.float_to_string(_hit, true),
		"D. cat.": (DamageTypes.find_key(_damage_type) as String).capitalize(),
		"Rank": (Ranks.find_key(_rank) as String).capitalize(),
		"Range": get_range_text(),
		"Weight": Utilities.float_to_string(_weight, true),
		"Critical": Utilities.float_to_string(_crit, true)
	}
	return Table.from_dictionary(table, 5)


func get_weapon_triangle_advantage(weapon: Weapon, _distance: int) -> AdvantageState:
	if weapon:
		if 1 << weapon.get_type() & _advantage_types:
			return AdvantageState.ADVANTAGE
		elif 1 << weapon.get_type() & _disadvantage_types:
			return AdvantageState.DISADVANTAGE
		else:
			return AdvantageState.NEUTRAL
	else:
		return AdvantageState.NEUTRAL


func get_hit_bonus(weapon: Weapon, distance: int) -> float:
	if get_weapon_triangle_advantage(weapon, distance) == AdvantageState.ADVANTAGE:
		return INF
	else:
		return 0


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


func get_range_text() -> String:
	var max_range_text: String = Utilities.float_to_string(get_max_range(), true)
	if _min_range == get_max_range():
		return max_range_text
	else:
		return "{min}-{max}".format({"min": str(get_min_range()), "max": max_range_text})


func get_mode_name() -> String:
	if _mode_name:
		return "{name} ({type})".format({"name": resource_name, "type": _mode_name})
	else:
		return resource_name


func get_weapon_modes() -> Array[Weapon]:
	var modes: Array[Weapon] = [self]
	while modes[-1]._linked_weapon:
		modes.append(modes[-1]._linked_weapon)
	return modes


func _load_preset(old_preset: _Presets, new_preset: _Presets) -> void:
	const HEAVY_PRESETS: int = 1 << _Presets.BRAVE | 1 << _Presets.STATUS | 1 << _Presets.DIAMOND
	if 1 << new_preset & HEAVY_PRESETS:
		_heavy_weapon = true
	elif 1 << old_preset & HEAVY_PRESETS:
		_heavy_weapon = false
	_rank = _get_preset_rank(new_preset)
	_might += (_get_preset_might(new_preset) - _get_preset_might(old_preset))
	_weight += _get_preset_weight(new_preset) + _get_preset_weight(old_preset)
	_hit += _get_preset_hit(new_preset) - _get_preset_hit(old_preset)
	_crit += _get_preset_crit(new_preset) - _get_preset_crit(old_preset)
	_price += _get_preset_price(new_preset) - _get_preset_price(old_preset)
	_max_uses += (_get_preset_durability(new_preset) - _get_preset_durability(old_preset))
	_flavor_text = _get_preset_flavor_text(new_preset)
	_description = _get_preset_description(new_preset)


func _load_heavy_modifiers() -> void:
	var heavy_multiplier: int = 1 if _heavy_weapon else -1

	_might += (_HEAVY_WEIGHT_MODIFIER * heavy_multiplier)
	_weight += (_HEAVY_WEIGHT_MODIFIER * heavy_multiplier)
	_hit += (_HEAVY_HIT_MODIFIER * heavy_multiplier)
	_price += (_HEAVY_PRICE_MODIFIER * heavy_multiplier)
	if _max_uses == 0:
		_max_uses += (_HEAVY_DURABILITY_MODIFIER * heavy_multiplier)
	_flavor_text = _get_preset_flavor_text(_preset)


func _get_preset_rank(preset: _Presets) -> Ranks:
	match preset:
		_Presets.IRON, _Presets.SLIM, _Presets.TRAINING, _Presets.MEME:
			return Ranks.D
		_Presets.BRONZE, _Presets.ANTI_MONSTER:
			return Ranks.C
		_Presets.STEEL, _Presets.KILLER, _Presets.REAVER:
			return Ranks.B
		_Presets.SILVER, _Presets.BRAVE:
			return Ranks.A
		_Presets.MASTER, _Presets.DIAMOND:
			return Ranks.S
		_:
			return Ranks.DISABLED


func _get_preset_might(preset: _Presets) -> float:
	match preset:
		_Presets.IRON:
			return 0
		_Presets.SLIM:
			return -2
		_Presets.TRAINING, _Presets.MEME:
			return -3
		_Presets.BRONZE:
			return 5
		_Presets.ANTI_MONSTER:
			return 3
		_Presets.STEEL:
			return 8
		_Presets.KILLER:
			return 5
		_Presets.REAVER, _Presets.BRAVE:
			return 7
		_Presets.SILVER:
			return 12
		_Presets.MASTER:
			return 14
		_Presets.DIAMOND:
			return 16
		_:
			return 0


func _get_preset_weight(preset: _Presets) -> float:
	match preset:
		_Presets.IRON:
			return 0
		_Presets.SLIM:
			return -2
		_Presets.TRAINING, _Presets.MEME:
			return -1
		_Presets.BRONZE:
			return 2
		_Presets.STEEL, _Presets.KILLER:
			return 1
		_Presets.ANTI_MONSTER, _Presets.REAVER, _Presets.SILVER, _Presets.BRAVE:
			return 3
		_Presets.MASTER, _Presets.DIAMOND:
			return 4
		_Presets.STATUS:
			return 6
		_:
			return 0


func _get_preset_hit(preset: _Presets) -> float:
	match preset:
		_Presets.IRON, _Presets.TRAINING, _Presets.ANTI_MONSTER, _Presets.STEEL:
			return 0
		_Presets.MEME, _Presets.BRONZE:
			return -5
		_Presets.SLIM:
			return INF
		_Presets.KILLER, _Presets.SILVER, _Presets.STATUS:
			return 5
		_Presets.BRAVE:
			return -5
		_Presets.REAVER, _Presets.MASTER, _Presets.DIAMOND:
			return -10
		_:
			return 0


func _get_preset_crit(preset: _Presets) -> float:
	match preset:
		_Presets.TRAINING:
			return -10
		_Presets.KILLER:
			return 25
		_:
			return 0


func _get_preset_price(preset: _Presets) -> int:
	match preset:
		_Presets.IRON:
			return 10
		_Presets.SLIM:
			return 12
		_Presets.TRAINING:
			return 7
		_Presets.MEME:
			return 4
		_Presets.BRONZE:
			return 20
		_Presets.ANTI_MONSTER:
			return 26
		_Presets.STEEL:
			return 30
		_Presets.KILLER:
			return 32
		_Presets.REAVER:
			return 35
		_Presets.SILVER:
			return 40
		_Presets.BRAVE:
			return 47
		_Presets.STATUS:
			return 42
		_Presets.MASTER, _Presets.DIAMOND:
			return 50
		_:
			return 0


func _get_preset_durability(preset: _Presets) -> int:
	match preset:
		_Presets.IRON, _Presets.MEME:
			return 20
		_Presets.SLIM, _Presets.BRONZE, _Presets.MASTER:
			return 30
		_Presets.TRAINING, _Presets.DIAMOND:
			return 50
		_Presets.ANTI_MONSTER, _Presets.KILLER, _Presets.SILVER:
			return 25
		_Presets.STEEL:
			return 40
		_Presets.REAVER, _Presets.BRAVE:
			return 15
		_Presets.STATUS:
			return 10
		_:
			return 0


func _get_preset_flavor_text(preset: _Presets) -> String:
	var type_name: String = _get_type_name().to_lower()
	match preset:
		_Presets.IRON:
			if _heavy_weapon:
				return "A heavy %s made with cheap wrought iron." % type_name
			else:
				return "A cheap %s made with wrought iron." % type_name
		_Presets.SLIM:
			return (
				"A lightweight %s that is easy to wield but does not deal much damage." % type_name
			)
		_Presets.TRAINING:
			return "A basic wooden %s that increases the user's learning speed." % type_name
		_Presets.BRONZE:
			if _heavy_weapon:
				return "A basic heavy %s made of a strong bronze alloy." % type_name
			else:
				return "A basic %s made of a strong bronze alloy." % type_name
		_Presets.ANTI_MONSTER:
			return "A %s with a holy, banishing enchantment." % type_name
		_Presets.STEEL:
			if _heavy_weapon:
				return "A basic yet well-built heavy %s made from steel." % type_name
			else:
				return "A basic yet well-built %s made from steel." % type_name
		_Presets.KILLER:
			return "A sharp-edged %s forged from an ironsand steel." % type_name
		# Skipping Reaver.
		_Presets.SILVER:
			if _heavy_weapon:
				return "A powerful, heavy steel %s made with a beautiful silver finish." % type_name
			else:
				return (
					"A strong yet lightweight steel %s made with a beautiful silver finish."
					% type_name
				)
		_Presets.BRAVE:
			return "A heavy yet deadly %s that strikes twice in a single attack." % type_name
		# Skipping Status.
		_Presets.MASTER:
			return (
				"A beautiful %s covered in bands from the wootz steel that forged it." % type_name
			)
		_Presets.DIAMOND:
			return (
				"An expensive and powerful wootz steel %s reinforced with a diamond edge."
				% type_name
			)
		_:
			return (
				'Error: No flavor text defined for preset "%s".' % str(_Presets.find_key(_preset))
			)


func _get_preset_description(preset: _Presets) -> String:
	match preset:
		_Presets.TRAINING:
			return "x2 EV gain."
		_Presets.ANTI_MONSTER:
			return "Effective against monsters."
		_Presets.KILLER:
			return "Increased critical hit rate."
		_Presets.REAVER:
			return "Reverses the weapon triangle."
		_Presets.BRAVE:
			return "+1 primary strike and +1 c. s. strike."
		_:
			# No description for other presets;
			# They either have no special effects or have custom descriptions.
			return ""


func _get_type_name() -> String:
	if _heavy_weapon:
		match _type:
			Types.SWORD:
				return "Blade"
			Types.SPEAR:
				return "Greatspear"
			Types.AXE:
				return "Greataxe"
			Types.BOW:
				return "Crossbow"
			Types.KNIFE:
				return "Dagger"
			_:
				return str(Types.find_key(_type)).capitalize()
	else:
		return str(Types.find_key(_type)).capitalize()


func _clone() -> Weapon:
	var clone := Weapon.new()
	clone._might = _might
	clone._weight = _weight
	clone._hit = _hit
	clone._crit = _crit
	clone._min_range = _min_range
	clone._max_range = _max_range
	return clone


func _update_name() -> void:
	resource_name = (str(_Presets.find_key(_preset)).capitalize() + " " + _get_type_name())
