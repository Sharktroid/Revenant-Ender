class_name CombatStage
## Object that represents one attack in a round of combat.
extends RefCounted

## The possible results of a combat stage
enum AttackTypes { HIT, MISS, CRIT }

## Any rate below this value is set to 0%
const MIN_RATE: int = 5
## Any rate above this value is set to 100%
const MAX_RATE: int = 95

## The unit who is attacking.
var attacker: Unit
## The unit who is being attacked.
var defender: Unit
## The type of attack for this round of combat.
var attack_type: AttackTypes

var _combat_art: CombatArt
var _initial: bool = false

func _init(attacking_unit: Unit, defending_unit: Unit, combat_art: CombatArt = NullArt.new(), initial: bool = false) -> void:
	attacker = attacking_unit
	defender = defending_unit
	_combat_art = combat_art
	_initial = initial


func generate_attack_type() -> AttackTypes:
	if get_hit_rate() > randi_range(0, 99):
		if get_crit_rate() > randi_range(0, 99):
			return AttackTypes.CRIT
		else:
			return AttackTypes.HIT
	else:
		return AttackTypes.MISS


## Gets the true attack value of the attacker
func get_attack() -> float:
	var weapon: Weapon = attacker.get_weapon()
	if weapon:
		var effectiveness_multiplier: int = (
			2 if weapon.get_effective_classes() & defender.unit_class.get_armor_classes() else 1
		)
		var attack: float = (
			_combat_art.get_attack(attacker)
			+ _combat_art.get_might(attacker)
			+ weapon.get_damage_bonus(defender.get_weapon(), _get_distance())
			+ attacker.get_authority_modifier(defender)
		)
		return effectiveness_multiplier * attack
	return 0


## Gets the damage done with a normal attack
func get_damage() -> float:
	return maxf(0, get_attack() - _get_current_defense())


## Gets the damage done with a crit
func get_crit_damage() -> float:
	var crit_damage: float = (
		get_attack() * 2 - _get_current_defense()
	)
	return maxf(0, crit_damage)


## Gets the hit rate against an enemy
func get_hit_rate() -> int:
	var weapon: Weapon = attacker.get_weapon()
	if weapon:  # No point in doing something more elaborate and complicated.
		var hit_bonus: float = weapon.get_hit_bonus(defender.get_weapon(), _get_distance())
		var authority_bonus: int = Unit.AUTHORITY_HIT_BONUS * attacker.get_authority_modifier(defender)
		return _adjust_rate(
			roundi(clampf(attacker.get_hit() - defender.get_avoid() + hit_bonus + authority_bonus, 0, 100))
		)
	return 0


## Gets the crit rate against an enemy
func get_crit_rate() -> int:
	var critical_avoid: float = (
		defender.get_critical_avoid()
		+ defender.get_authority_modifier(attacker) * Unit.AUTHORITY_CRITICAL_AVOID_BONUS
	)
	return _adjust_rate(roundi(clampf(attacker.get_crit() - critical_avoid, 0, 100)))


## The displayed total damage dealt by the unit.
func get_displayed_damage(
	crit: bool, check_miss: bool = true, check_crit: bool = true
) -> float:
	if get_hit_rate() <= 0 and check_miss:
		return 0
	else:
		if check_crit:
			var crit_rate: float = get_crit_rate()
			if crit_rate >= 100:
				return get_crit_damage()
			elif crit_rate <= 0:
				return get_damage()
		return get_crit_damage() if crit else get_damage()


func _get_distance() -> int:
	return roundi(Utilities.get_tile_distance(attacker.position, defender.position))


# Gets the rate, with the min and max rates
func _adjust_rate(rate: int) -> int:
	if rate < MIN_RATE:
		return 0
	elif rate > MAX_RATE:
		return 100
	else:
		return rate


## Gets the quantity of the unit's current attack stat
func _get_current_attack() -> int:
	if attacker.get_weapon():
		match attacker.get_weapon().get_damage_type():
			Weapon.DamageTypes.PHYSICAL:
				return attacker.get_strength()
			Weapon.DamageTypes.RANGED:
				return attacker.get_pierce()
			Weapon.DamageTypes.MAGICAL:
				return attacker.get_intelligence()
	return 0


## Gets the defender's defense type against a weapon
func _get_current_defense() -> int:
	return defender.get_authority_modifier(attacker) + _combat_art.get_defense(attacker, defender)
