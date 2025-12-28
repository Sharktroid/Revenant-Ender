class_name CombatStage
## Object that represents one attack in a round of combat.
extends RefCounted

## The possible results of a combat stage
enum AttackTypes { HIT, MISS, CRIT }

### The unit who is attacking.
#var get_attacker(): Unit
### The unit who is being attacked.
#var get_defender(): Unit
## The type of attack for this round of combat.
var _attack_type: AttackTypes

var _combat_art: CombatArt
var _initial: bool = false
var _combat: Combat
var _attacker_stage: bool
var _primary_strike: bool


func _init(
	combat: Combat, attacker_stage: bool, primary_strike: bool, initial: bool = false
) -> void:
	#get_attacker() = combat._attacker
	#get_defender() = combat._defender
	_attacker_stage = attacker_stage
	_primary_strike = primary_strike
	_combat_art = combat._combat_art
	_combat = combat
	_initial = initial
	_attack_type = _generate_attack_type()


func _generate_attack_type() -> AttackTypes:
	if _combat.get_hit_rate(get_attacker()) > randi_range(0, 99):
		if _combat.get_crit_rate(get_attacker()) > randi_range(0, 99):
			return AttackTypes.CRIT
		else:
			return AttackTypes.HIT
	else:
		return AttackTypes.MISS


## Gets the true attack value of the get_attacker()
func _get_attack() -> float:
	var weapon: Weapon = get_attacker().get_weapon()
	if weapon:
		var effectiveness_multiplier: int = (
			2
			if weapon.get_effective_classes() & get_defender().unit_class.get_armor_classes()
			else 1
		)
		var attack: float = (
			_combat_art.get_attack(get_attacker())
			+ _combat_art.get_might(get_attacker())
			+ weapon.get_damage_bonus(get_defender().get_weapon(), _get_distance())
			+ get_attacker().get_authority_modifier(get_defender())
		)
		return effectiveness_multiplier * attack
	return 0


## Gets the damage done with a normal attack
func get_damage() -> float:
	return clampf(_get_unclamped_damage(), 0, 99)


func _get_unclamped_damage() -> float:
	match _attack_type:
		AttackTypes.CRIT:
			return _get_crit_damage()
		AttackTypes.MISS:
			return 0
		_:
			return _get_hit_damage()


## Gets the damage done with a normal attack
func _get_hit_damage() -> float:
	return maxf(
		0,
		_combat_art.get_damage(_get_attack(), _get_current_defense(), get_defender().current_health)
	)


## Gets the damage done with a crit
func _get_crit_damage() -> float:
	return maxf(0, _combat_art.get_crit_damage(_get_attack(), _get_current_defense()))


## The displayed total damage dealt by the unit.
func _get_displayed_damage(crit: bool, check_miss: bool = true, check_crit: bool = true) -> float:
	if _combat.get_hit_rate(get_attacker()) <= 0 and check_miss:
		return 0
	else:
		if check_crit:
			var crit_rate: float = _combat.get_crit_rate(get_attacker())
			if crit_rate >= 100:
				return _get_crit_damage()
			elif crit_rate <= 0:
				return _get_hit_damage()
		return _get_crit_damage() if crit else _get_hit_damage()


func get_recoil() -> float:
	return floorf(get_attacker().get_weapon().get_recoil_multiplier() * _get_hit_damage())


func get_attack_type() -> AttackTypes:
	return _attack_type


func get_attacker() -> Unit:
	return _combat._attacker if _attacker_stage else _combat._defender


func get_defender() -> Unit:
	return _combat._defender if _attacker_stage else _combat._attacker


func _get_distance() -> int:
	return roundi(Utilities.get_tile_distance(get_attacker().position, get_defender().position))


## Gets the get_defender()'s defense type against a weapon
func _get_current_defense() -> int:
	return (
		get_defender().get_authority_modifier(get_attacker())
		+ _combat_art.get_defense(get_attacker(), get_defender())
	)
