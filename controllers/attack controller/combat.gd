## Class that stores a round of combat.
class_name Combat
extends RefCounted

## Any rate below this value is set to 0%
const MIN_RATE: int = 5
## Any rate above this value is set to 100%
const MAX_RATE: int = 95

var _attacker: Unit
var _defender: Unit
var _combat_art: CombatArt
var _combat_round: Array[Stage]
var _distance: int


func _init(attacker: Unit, defender: Unit, distance: int, combat_art: CombatArt) -> void:
	_attacker = attacker
	_defender = defender
	_combat_art = combat_art
	_distance = distance
	_combat_round = [Stage.new(self, true, true, true)]
	if _combat_art and _combat_art.get_bonus_strikes():
		_combat_round.append(Stage.new(self, true, true))
	if _can_counter():
		_combat_round.append(Stage.new(self, false, true))
	if _attacker.can_follow_up(_defender):
		_combat_round.append(Stage.new(self, true, false))
	elif _can_counter() and _defender.can_follow_up(_attacker):
		_combat_round.append(Stage.new(self, false, false))


func _can_counter() -> bool:
	if _defender.get_weapon() != null:
		return _defender.get_weapon().in_range(_distance)
	return false


func get_attack_stages() -> Array[Stage]:
	if is_combat_art_active(get_attacker()) and _combat_art.get_rounds() > 1:
		var attack_queue: Array[Stage] = []
		for num: int in _combat_art.get_rounds():
			attack_queue.append_array(_combat_round)
		return attack_queue
	return _combat_round


## Gets the hit rate against an enemy
func get_hit_rate(unit: Unit) -> int:
	var weapon: Weapon = unit.get_weapon()
	if weapon:  # No point in doing something more elaborate and complicated.
		var hit_bonus: float = weapon.get_hit_bonus(_get_enemy(unit).get_weapon(), _get_distance())
		var authority_bonus: int = (
			Unit.AUTHORITY_HIT_BONUS * unit.get_authority_modifier(_get_enemy(unit))
		)
		return _adjust_rate(_get_base_rate() + hit_bonus + authority_bonus)
	return 0


## Gets the crit rate against an enemy
func get_crit_rate(unit: Unit) -> int:
	var critical_avoid: float = (
		_get_enemy(unit).get_critical_avoid()
		+ _get_enemy(unit).get_authority_modifier(unit) * Unit.AUTHORITY_CRITICAL_AVOID_BONUS
	)
	return _adjust_rate(roundi(clampf(unit.get_crit() - critical_avoid, 0, 100)))


func create_attack_arrows() -> Array[AttackArrow]:
	var attacker_sum: float = 0
	var defender_sum: float = 0
	var attacker_critical_sum: float = 0
	var defender_critical_sum: float = 0
	var arrows: Array[AttackArrow] = []
	var initiation: bool = true
	for attack: Stage in get_attack_stages():
		if attack.get_attacker() == _attacker:
			attacker_sum += _get_displayed_damage(initiation, false, _attacker)
			attacker_critical_sum += _get_displayed_damage(initiation, true, _attacker)
		else:
			defender_sum += _get_displayed_damage(initiation, false, _defender)
			defender_critical_sum += _get_displayed_damage(initiation, true, _defender)
		const DIRS = AttackArrow.DIRECTIONS
		var direction: AttackArrow.DIRECTIONS = (
			DIRS.RIGHT if attack.get_attacker() == _attacker else DIRS.LEFT
		)
		var event: AttackArrow.EVENTS = _get_event(
			attacker_sum if attack.get_attacker() == _attacker else defender_sum,
			attacker_critical_sum if attack.get_attacker() == _attacker else defender_critical_sum,
			attack
		)
		var attack_arrow := AttackArrow.instantiate(
			direction,
			_get_displayed_damage(initiation, false, attack.get_attacker()),
			_get_displayed_damage(initiation, true, attack.get_attacker()),
			attack.get_recoil(_get_displayed_damage(initiation, false, attack.get_attacker())),
			event,
			attack.get_attacker().faction.color
		)
		arrows.append(attack_arrow)
		initiation = false
	return arrows


func get_total_damage(crit: bool, unit: Unit) -> float:
	var attack_stages: Array[Stage] = get_attack_stages()
	var damage_reducer: Callable = func(accumulator: float, attack: Stage) -> float:
		if attack.get_attacker() == unit:
			return accumulator + _get_displayed_damage(attack_stages[0] == attack, crit, unit)
		return accumulator
	return get_attack_stages().reduce(damage_reducer, 0)


func get_attacker() -> Unit:
	return _attacker


func get_defender() -> Unit:
	return _defender


## Gets the true attack value of the get_attacker()
func get_attack(initiation: float, unit: Unit) -> float:
	var weapon: Weapon = unit.get_weapon()
	if weapon:
		var effectiveness: bool = (
			weapon.get_effective_classes() & _get_enemy(unit).unit_class.get_armor_classes()
		)
		var effectiveness_multiplier: int = 2 if effectiveness else 1
		var attack: float = (
			_get_base_attack(initiation, unit)
			+ weapon.get_damage_bonus(_get_enemy(unit).get_weapon(), _get_distance())
			+ unit.get_authority_modifier(_get_enemy(unit))
		)
		return effectiveness_multiplier * attack
	return 0


func _get_base_attack(initiation: float, unit: Unit) -> float:
	if is_combat_art_active(unit):
		return _combat_art.get_attack(unit) + _combat_art.get_might(unit, initiation)
	else:
		return unit.get_attack(initiation)


## Gets the damage done with a normal attack
func get_hit_damage(initiation: bool, unit: Unit) -> float:
	return _get_base_damage(1, initiation, unit)


## Gets the damage done with a crit
func get_crit_damage(initiation: bool, unit: Unit) -> float:
	return _get_base_damage(2, initiation, unit)


func get_recoil(unit: Unit, damage: float) -> float:
	var recoil_multiplier: float = unit.get_weapon().get_recoil_multiplier()
	if is_combat_art_active(unit):
		recoil_multiplier += _combat_art.get_recoil_modifier()
	var unclamped_recoil: int = floori(recoil_multiplier * damage)
	return clampf(
		unclamped_recoil,
		-(get_attacker().get_hit_points() - get_attacker().current_health),
		get_attacker().current_health
	)


func _get_base_damage(multiplier: int, initiation: bool, unit: Unit) -> float:
	if is_combat_art_active(unit):
		return _combat_art.get_damage(
			get_attack(initiation, unit) * multiplier,
			_get_current_defense(_get_enemy(unit)),
			_get_enemy(unit).current_health
		)
	else:
		return get_attack(initiation, unit) * multiplier - _get_current_defense(_get_enemy(unit))


func _get_distance() -> int:
	return roundi(Utilities.get_tile_distance(_attacker.position, _defender.position))


func _get_base_rate() -> float:
	if _combat_art:
		return _combat_art.get_hit(_attacker) - _combat_art.get_avoid(_defender)
	else:
		return _attacker.get_hit() - _defender.get_avoid()


# Gets the rate, with the min and max rates
func _adjust_rate(rate: float) -> int:
	if rate < MIN_RATE:
		return 0
	elif rate > MAX_RATE:
		return 100
	else:
		return roundi(rate)


## Gets the unit's defense type against a weapon
func _get_current_defense(unit: Unit) -> int:
	var defense: int = unit.get_authority_modifier(_get_enemy(unit)) + _get_defense_stat(unit)
	if is_combat_art_active(_get_enemy(unit)):
		return _combat_art.get_defense(defense, unit)
	return defense


func _get_defense_stat(unit: Unit) -> int:
	var enemy: Unit = _get_enemy(unit)
	match enemy.get_weapon().get_damage_type():
		Weapon.DamageTypes.PHYSICAL:
			return unit.get_defense()
		Weapon.DamageTypes.RANGED:
			return unit.get_armor()
		Weapon.DamageTypes.MAGICAL:
			return unit.get_resistance()
		var damage_type:
			push_error("Damage Type %s Invalid" % damage_type)
			return 0


## The displayed total damage dealt by the unit.
func _get_displayed_damage(
	initiation: bool, crit: bool, unit: Unit, check_miss: bool = true, check_crit: bool = true
) -> float:
	if get_hit_rate(unit) <= 0 and check_miss:
		return 0
	else:
		if check_crit:
			var crit_rate: float = get_crit_rate(unit)
			if crit_rate >= 100:
				return get_crit_damage(initiation, unit)
			elif crit_rate <= 0:
				return get_hit_damage(initiation, unit)
		return get_crit_damage(initiation, unit) if crit else get_hit_damage(initiation, unit)


func _get_event(
	current_sum: float, current_critical_sum: float, attack: Stage
) -> AttackArrow.EVENTS:
	if get_hit_rate(attack.get_attacker()) <= 0:
		return AttackArrow.EVENTS.MISS
	if current_sum >= attack.get_defender().current_health:
		return AttackArrow.EVENTS.KILL
	elif current_critical_sum >= attack.get_defender().current_health:
		return AttackArrow.EVENTS.CRIT_KILL
	return AttackArrow.EVENTS.NONE


func _get_enemy(unit: Unit) -> Unit:
	return _attacker if unit == _defender else _defender


func is_combat_art_active(unit: Unit) -> bool:
	return (
		_combat_art
		and unit == get_attacker()
		and _combat_art.is_active(unit, _get_enemy(unit), _distance)
	)


class Stage:
	## Object that represents one attack in a round of combat.
	extends RefCounted

	## The possible results of a combat stage
	enum AttackTypes { HIT, MISS, CRIT }

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
		_attacker_stage = attacker_stage
		_primary_strike = primary_strike
		_combat_art = combat._combat_art
		_combat = combat
		_initial = initial
		_attack_type = _generate_attack_type()

	## Gets the damage done with a normal attack
	func get_damage() -> int:
		return clampi(roundi(_get_unclamped_damage()), 0, get_defender().current_health)

	func get_recoil(damage: float) -> int:
		return roundi(_combat.get_recoil(get_attacker(), damage))

	func get_attack_type() -> AttackTypes:
		return _attack_type

	func get_attacker() -> Unit:
		return _combat._attacker if _attacker_stage else _combat._defender

	func get_defender() -> Unit:
		return _combat._defender if _attacker_stage else _combat._attacker

	func _generate_attack_type() -> AttackTypes:
		if _combat.get_hit_rate(get_attacker()) > randi_range(0, 99):
			if _combat.get_crit_rate(get_attacker()) > randi_range(0, 99):
				return AttackTypes.CRIT
			else:
				return AttackTypes.HIT
		else:
			return AttackTypes.MISS

	func _get_unclamped_damage() -> float:
		match _attack_type:
			AttackTypes.CRIT:
				return _combat.get_crit_damage(_initial, get_attacker())
			AttackTypes.MISS:
				return 0
			_:
				return _combat.get_hit_damage(_initial, get_attacker())

	func _get_distance() -> int:
		return roundi(Utilities.get_tile_distance(get_attacker().position, get_defender().position))
