## Autoload that handles combat and battle animations.
extends Node


## Initiates combat between an attacker and a defender.
func combat(attacker: Unit, defender: Unit) -> void:
	CursorController.disable()
	## The list of attacks that will be done in this round of combat.
	var attack_queue: Array[CombatStage] = [CombatStage.new(attacker, defender)]
	if _can_counter(attacker, defender):
		attack_queue.append(CombatStage.new(defender, attacker))
	if attacker.can_follow_up(defender):
		attack_queue.append(CombatStage.new(attacker, defender))
	elif defender.can_follow_up(attacker):
		attack_queue.append(CombatStage.new(defender, attacker))
	await _map_combat(attacker, defender, attack_queue)
	CursorController.enable()
	GameController.remove_from_input_stack()


func _receive_input(_event: InputEvent) -> void:
	pass


func _can_counter(attacker: Unit, defender: Unit) -> bool:
	if defender.get_weapon() != null:
		return defender.get_weapon().in_range(
			roundi(Utilities.get_tile_distance(attacker.position, defender.position))
		)
	return false


## Initiates combat between two units using map animations.
func _map_combat(attacker: Unit, defender: Unit, attack_queue: Array[CombatStage]) -> void:
	var hp_bar := MapCombatDisplay.instantiate(attacker, defender)
	MapController.get_ui().add_child(hp_bar)
	var attacker_animation: MapAttack = await MapAttack.new(attacker, defender.position)
	attacker.get_parent().add_child(attacker_animation)
	var defender_animation: MapAttack = await MapAttack.new(defender, attacker.position)
	defender.get_parent().add_child(defender_animation)
	attacker.visible = false
	defender.visible = false
	var attacker_starting_hp: float = attacker.current_health
	var defender_starting_hp: float = defender.current_health
	## Delay between attacks
	const DELAY: float = 0.25
	for combat_round: CombatStage in attack_queue:
		await get_tree().create_timer(DELAY).timeout
		await _map_attack(
			combat_round.attacker,
			combat_round.defender,
			attacker_animation if combat_round.attacker == attacker else defender_animation,
			defender_animation if combat_round.defender == defender else attacker_animation,
			combat_round.attack_type
		)
		if attacker.current_health <= 0 or defender.current_health <= 0:
			break
	await get_tree().create_timer(DELAY).timeout

	hp_bar.queue_free()
	if defender.current_health <= 0:
		await _kill(defender, defender_animation)
	if attacker.current_health <= 0:
		await _kill(attacker, attacker_animation)

	await _give_exp(attacker, defender, defender_starting_hp)
	await _give_exp(defender, attacker, attacker_starting_hp)

	attacker_animation.queue_free()
	defender_animation.queue_free()

	for unit: Unit in [attacker, defender]:
		if unit.dead:
			unit.queue_free()
		else:
			unit.visible = true


## One round of map combat.
func _map_attack(
	attacker: Unit,
	defender: Unit,
	attacker_animation: MapAttack,
	defender_animation: MapAttack,
	attack_type: CombatStage.AttackTypes
) -> void:
	attacker_animation.play_animation()
	await attacker_animation.arrived
	if attack_type == CombatStage.AttackTypes.MISS:
		await AudioPlayer.play_sound_effect(preload("res://audio/sfx/miss.ogg"))
	else:
		#region Hit
		var is_crit: bool = attack_type == CombatStage.AttackTypes.CRIT
		var old_health: int = ceili(defender.current_health)

		var get_damage: Callable = func() -> float:
			return minf(
				defender.current_health,
				attacker.get_crit_damage(defender) if is_crit else attacker.get_damage(defender)
			)
		var damage: int = roundi(get_damage.call() as float)
		var new_health: int = old_health - damage

		# The time that the health bar takes to scroll down from full health to none
		const HEALTH_SCROLL_DURATION: float = 0.5
		var duration: float = HEALTH_SCROLL_DURATION * damage / defender.get_hit_points()
		var tween: Tween = defender.create_tween()
		tween.set_parallel()
		tween.tween_interval(0.1)
		tween.tween_property(defender, ^"current_health", new_health, duration)
		var sfx_timer: SceneTreeTimer = _play_hit_sound_effect(
			old_health, new_health, is_crit, attacker
		)
		if is_crit:
			await defender_animation.crit_damage_animation()
		else:
			await defender_animation.damage_animation()
		if tween.is_running():
			await tween.finished
		if sfx_timer.time_left > 0:
			await sfx_timer.timeout
		#endregion
	if attacker_animation.is_running():
		await attacker_animation.completed


## Kills a unit.
func _kill(unit: Unit, unit_animation: MapAttack) -> void:
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/death_fade.ogg"))
	var sync_fade: Tween = unit.create_tween()
	sync_fade.tween_method(unit_animation.set_alpha, 1.0, 0.0, Unit.FADE_AWAY_DURATION)
	await sync_fade.finished
	unit_animation.visible = false
	unit.dead = true
	await get_tree().process_frame  # Prevents visual bug


## Gets the experience for damaging a unit.
func _get_combat_exp(distributing_unit: Unit, damage: float) -> float:
	var base_exp: float = (
		Unit.ONE_ROUND_EXP_BASE * Unit.EXP_MULTIPLIER ** (distributing_unit.level - 1)
	)
	var chip_exp: float = (
		base_exp * damage / distributing_unit.get_hit_points() * (1 - Unit.KILL_EXP_PERCENT)
	)
	if distributing_unit.current_health <= 0:
		return chip_exp + base_exp * Unit.KILL_EXP_PERCENT  # Chip EXP + Kill EXP
	else:
		return chip_exp


## Gives the receiving unit experience from damaging an opponent.
func _give_exp(receiving_unit: Unit, distributing_unit: Unit, old_hp: float) -> void:
	if not receiving_unit.dead:
		if receiving_unit.faction.player_type == Faction.PlayerTypes.HUMAN:
			var exp_bar := EXPBar.instantiate(
				receiving_unit,
				_get_combat_exp(distributing_unit, old_hp - distributing_unit.current_health)
			)
			MapController.get_ui().add_child(exp_bar)
			await exp_bar.tree_exited
		else:
			receiving_unit.total_exp += _get_combat_exp(
				distributing_unit, old_hp - distributing_unit.current_health
			)


## Plays sound effect for hit,
## and returns a timer that times out when the sound effect has finished playing
func _play_hit_sound_effect(
	old_health: int, new_health: int, is_crit: bool, attacker: Unit
) -> SceneTreeTimer:
	if is_crit and new_health <= 0:
		const SMASH: AudioStreamOggVorbis = preload("res://audio/sfx/earthbound_smash.ogg")
		const MORTAL: AudioStreamOggVorbis = preload("res://audio/sfx/earthbound_mortal.ogg")
		var crit_sfx: AudioStreamOggVorbis = (
			SMASH if MapController.map.is_faction_friendly_to_human(attacker.faction) else MORTAL
		)
		AudioPlayer.play_sound_effect(crit_sfx)
		return get_tree().create_timer(crit_sfx.get_length())
	else:
		## Hit SFX is broken into two parts
		## Hit A changes if the attack is a crit, Hit B changes if the attack is a mortal blow
		const HIT_A_HEAVY: AudioStream = preload("res://audio/sfx/hit_a_heavy.ogg")
		const HIT_A_CRIT: AudioStream = preload("res://audio/sfx/hit_a_crit.ogg")
		const DELAY: int = 5
		var hit_a: AudioStream = HIT_A_CRIT if is_crit else HIT_A_HEAVY
		var get_hit_b_sound_effect: Callable = func() -> AudioStream:
			if new_health <= 0:
				return preload("res://audio/sfx/hit_b_fatal.ogg")  # Fatal SFX
			elif old_health - new_health == 0:
				return preload("res://audio/sfx/no_damage.ogg")  # No damage SFX
			else:
				return preload("res://audio/sfx/hit_b_heavy.ogg")  # Normal SFX
		var hit_b: AudioStream = get_hit_b_sound_effect.call()
		var sfx_tween: Tween = create_tween()
		sfx_tween.set_speed_scale(60)
		sfx_tween.tween_callback(AudioPlayer.play_sound_effect.bind(hit_a))
		sfx_tween.tween_callback(AudioPlayer.play_sound_effect.bind(hit_b)).set_delay(DELAY)
		return get_tree().create_timer(
			maxf(hit_a.get_length(), float(DELAY) / 60 + hit_b.get_length())
		)


## Object that represents one attack in a round of combat.
class CombatStage:
	extends RefCounted

	## The possible results of a combat stage
	enum AttackTypes { HIT, MISS, CRIT }

	## The unit who is attacking.
	var attacker: Unit
	## The unit who is being attacked.
	var defender: Unit
	## The type of attack for this round of combat.
	var attack_type: AttackTypes

	func _init(attacking_unit: Unit, defending_unit: Unit) -> void:
		attacker = attacking_unit
		defender = defending_unit
		attack_type = _generate_attack_type()

	func _generate_attack_type() -> AttackTypes:
		if attacker.get_hit_rate(defender) > randi_range(0, 99):
			if attacker.get_crit_rate(defender) > randi_range(0, 99):
				return AttackTypes.CRIT
			else:
				return AttackTypes.HIT
		else:
			return AttackTypes.MISS
