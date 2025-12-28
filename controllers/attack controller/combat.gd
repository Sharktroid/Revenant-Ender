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
var _combat_round: Array[CombatStage]
var _distance: int

func _init(attacker: Unit, defender: Unit, distance: int, combat_art: CombatArt) -> void:
	_attacker = attacker
	_defender = defender
	_combat_art = combat_art if combat_art else NullArt.new()
	_distance = distance
	_combat_round = _combat_art.get_attack_queue(self)
	if _can_counter():
		_combat_round.append(CombatStage.new(self, false, true))
	if _attacker.can_follow_up(_defender):
		_combat_round.append(CombatStage.new(self, true, false))
	elif _can_counter() and _defender.can_follow_up(_attacker):
		_combat_round.append(CombatStage.new(self, false, false))


func _can_counter() -> bool:
	if _defender.get_weapon() != null:
		return _defender.get_weapon().in_range(_distance)
	return false


func get_attack_stages() -> Array[CombatStage]:
	var attack_queue: Array[CombatStage] = []
	for num: int in _combat_art.get_rounds():
		attack_queue.append_array(_combat_round)
	return attack_queue


## Gets the hit rate against an enemy
func get_hit_rate(unit: Unit) -> int:
	var weapon: Weapon = unit.get_weapon()
	if weapon:  # No point in doing something more elaborate and complicated.
		var enemy: Unit = _attacker if unit == _defender else _defender
		var hit_bonus: float = weapon.get_hit_bonus(enemy.get_weapon(), _get_distance())
		var authority_bonus: int = (
			Unit.AUTHORITY_HIT_BONUS * unit.get_authority_modifier(enemy)
		)
		return _adjust_rate(_get_base_rate() + hit_bonus + authority_bonus)
	return 0


## Gets the crit rate against an enemy
func get_crit_rate(unit: Unit) -> int:
	var enemy: Unit = _attacker if unit == _defender else _defender
	var critical_avoid: float = (
		enemy.get_critical_avoid()
		+ enemy.get_authority_modifier(unit) * Unit.AUTHORITY_CRITICAL_AVOID_BONUS
	)
	return _adjust_rate(roundi(clampf(unit.get_crit() - critical_avoid, 0, 100)))


func create_attack_arrows() -> Array[AttackArrow]:
	var attacker_sum: float = 0
	var defender_sum: float = 0
	var attacker_critical_sum: float = 0
	var defender_critical_sum: float = 0
	var arrows: Array[AttackArrow] = []
	for attack: CombatStage in get_attack_stages():
		if attack.get_attacker() == _attacker:
			attacker_sum += attack._get_displayed_damage(false)
			attacker_critical_sum += attack._get_displayed_damage(true)
		else:
			defender_sum += attack._get_displayed_damage(false)
			defender_critical_sum += attack._get_displayed_damage(true)
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
			attack._get_displayed_damage(false),
			attack._get_displayed_damage(true),
			attack.get_recoil(),
			event,
			attack.get_attacker().faction.color
		)
		arrows.append(attack_arrow)
	return arrows


func get_total_damage(crit: bool, unit: Unit) -> float:
	var damage_reducer: Callable = func(
		accumulator: float, attack: CombatStage
	) -> float:
		if attack.get_attacker() == unit:
			return accumulator + attack._get_displayed_damage(crit)
		return accumulator
	return get_attack_stages().reduce(damage_reducer, 0)


func get_attacker() -> Unit:
	return _attacker


func get_defender() -> Unit:
	return _defender


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


func _get_event(
	current_sum: float, current_critical_sum: float, attack: CombatStage
) -> AttackArrow.EVENTS:
	#if attack.get_hit_rate() <= 0:
		#return AttackArrow.EVENTS.MISS
	if current_sum >= attack.get_defender().current_health:
		return AttackArrow.EVENTS.KILL
	elif current_critical_sum >= attack.get_defender().current_health:
		return AttackArrow.EVENTS.CRIT_KILL
	return AttackArrow.EVENTS.NONE
