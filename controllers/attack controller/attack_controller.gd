extends Node

enum AttackTypes { HIT, MISS, CRIT }

const DELAY: float = 0.25
const HEALTH_SCROLL_DURATION: float = 0.5

const HIT_B_DELAY: float = 5.0 / 60


func combat(attacker: Unit, defender: Unit) -> void:
	GameController.add_to_input_stack(self)
	CursorController.disable()
	var attack_queue: Array[CombatStage] = [CombatStage.new(attacker, defender)]
	var distance: int = roundi(Utilities.get_tile_distance(attacker.position, defender.position))
	if (
		defender.get_current_weapon() != null and defender.get_current_weapon().in_range(distance)
	):
		attack_queue.append(CombatStage.new(defender, attacker))
	if (
		attacker.has_skill_attribute(Skill.AllAttributes.FOLLOW_UP)
		and attacker.get_attack_speed() >= 5 + defender.get_attack_speed()
	):
		attack_queue.append(CombatStage.new(attacker, defender))
	await _map_combat(attacker, defender, attack_queue)
	CursorController.enable()
	GameController.remove_from_input_stack()


func receive_input(_event: InputEvent) -> void:
	pass


func _map_combat(attacker: Unit, defender: Unit, attack_queue: Array[CombatStage]) -> void:
	const HP_BAR_PATH: String = "res://controllers/attack controller/map_battle_info_display."
	const MapBattleHpBar = preload(HP_BAR_PATH + "gd")
	var hp_bar := preload(HP_BAR_PATH + "tscn").instantiate() as MapBattleHpBar
	hp_bar.attacker = attacker
	hp_bar.defender = defender
	MapController.get_ui().add_child(hp_bar)
	var attacker_animation: MapAttack = await MapAttack.new(attacker, defender.position)
	attacker.get_parent().add_child(attacker_animation)
	var defender_animation: MapAttack = await MapAttack.new(defender, attacker.position)
	defender.get_parent().add_child(defender_animation)
	attacker.visible = false
	defender.visible = false
	var attacker_starting_hp: float = attacker.current_health
	var defender_starting_hp: float = defender.current_health
	for combat_round: CombatStage in attack_queue:
		await get_tree().create_timer(DELAY).timeout
		await _map_attack(
			combat_round.attacker,
			combat_round.defender,
			attacker_animation if combat_round.attacker == attacker else defender_animation,
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


func _map_attack(
	attacker: Unit, defender: Unit, attacker_animation: MapAttack, attack_type: AttackTypes
) -> void:
	attacker_animation.play_animation()
	await attacker_animation.arrived
	if attack_type == AttackTypes.MISS:
		await AudioPlayer.play_sound_effect(preload("res://audio/sfx/miss.ogg"))
	else:
		#region Hit
		const HIT_A_HEAVY: AudioStream = preload("res://audio/sfx/hit_a_heavy.ogg")
		const HIT_A_CRIT: AudioStream = preload("res://audio/sfx/hit_a_crit.ogg")
		const HIT_B_HEAVY: AudioStream = preload("res://audio/sfx/hit_b_heavy.ogg")
		const HIT_B_FATAL: AudioStream = preload("res://audio/sfx/hit_b_fatal.ogg")

		var is_crit: bool = attack_type == AttackTypes.CRIT
		var hit_a: AudioStream = HIT_A_CRIT if is_crit else HIT_A_HEAVY
		var damage: int = (
			attacker.get_crit_damage(defender) if is_crit else attacker.get_damage(defender)
		)
		var old_health: int = ceili(defender.current_health)
		var new_health: int = maxi(floori(old_health - damage), 0)
		var hit_b: AudioStream = (
			HIT_B_FATAL
			if new_health <= 0
			else preload("res://audio/sfx/no_damage.ogg") if damage == 0 else HIT_B_HEAVY
		)

		var total_hp: int = defender.get_stat(Unit.Stats.HIT_POINTS)
		var duration: float = HEALTH_SCROLL_DURATION * (float(old_health - new_health) / total_hp)
		var tween: Tween = defender.create_tween()
		tween.set_parallel()
		tween.tween_interval(0.1)
		tween.tween_property(defender, "current_health", new_health, duration)
		AudioPlayer.play_sound_effect(hit_a)
		await get_tree().create_timer(HIT_B_DELAY).timeout
		await AudioPlayer.play_sound_effect(hit_b)
		if tween.is_running():
			await tween.finished
		#endregion
	attacker_animation.damage_dealt.emit()
	await attacker_animation.completed


func _kill(unit: Unit, unit_animation: MapAttack) -> void:
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/death_fade.ogg"))
	var sync_fade: Tween = unit.create_tween()
	sync_fade.tween_method(unit_animation.set_alpha, 1.0, 0.0, Unit.FADE_AWAY_DURATION)
	await sync_fade.finished
	unit_animation.visible = false
	unit.dead = true
	await get_tree().process_frame  # Prevents visual bug


func _get_combat_exp(distributing_unit: Unit, damage: float) -> float:
	var base_exp: float = (
		Unit.ONE_ROUND_EXP_BASE * Unit.EXP_MULTIPLIER ** (distributing_unit.level - 1)
	)
	var damage_percent: float = float(damage) / distributing_unit.get_stat(Unit.Stats.HIT_POINTS)
	var chip_exp: float = base_exp * damage_percent * (1 - Unit.KILL_EXP_PERCENT)
	var kill_exp: float = (
		base_exp * Unit.KILL_EXP_PERCENT if distributing_unit.current_health <= 0
		else 0.0
	)
	return chip_exp + kill_exp


func _give_exp(recieving_unit: Unit, distributing_unit: Unit, old_hp: float) -> void:
	if not recieving_unit.dead:
		if recieving_unit.faction.player_type == Faction.PlayerTypes.HUMAN:
			const EXP_BAR_PATH: String = "res://ui/exp_bar/exp_bar."
			const EXP_BAR_SCENE: PackedScene = preload(EXP_BAR_PATH + "tscn")
			const ExpBar = preload(EXP_BAR_PATH + "gd")
			var exp_bar := EXP_BAR_SCENE.instantiate() as ExpBar
			exp_bar.observing_unit = recieving_unit
			MapController.get_ui().add_child(exp_bar)
			exp_bar.play(
				_get_combat_exp(distributing_unit, old_hp - distributing_unit.current_health)
			)
			await exp_bar.tree_exited
		else:
			recieving_unit.total_exp += _get_combat_exp(
				distributing_unit, old_hp - distributing_unit.current_health
			)


class CombatStage:
	extends RefCounted
	var attacker: Unit
	var defender: Unit
	var attack_type: AttackTypes

	func _init(attacking_unit: Unit, defending_unit: Unit) -> void:
		attacker = attacking_unit
		defender = defending_unit
		var did_hit: bool = attacker.get_hit_rate(defender) > randi_range(0, 99)
		attack_type = (
			AttackTypes.MISS if not did_hit
			else AttackTypes.CRIT if attacker.get_crit_rate(defender) > randi_range(0, 99)
			else AttackTypes.HIT
		)
