class_name AttackController
extends RefCounted

enum attack_types {HIT, MISS, CRIT}

const DELAY: float = 0.25
const HEALTH_SCROLL_DURATION: float = 0.5
const HIT_A_HEAVY: AudioStream = preload("res://audio/sfx/hit_a_heavy.ogg")
const HIT_A_CRIT: AudioStream = preload("res://audio/sfx/hit_a_crit.ogg")
const HIT_B_HEAVY: AudioStream = preload("res://audio/sfx/hit_b_heavy.ogg")
const HIT_B_FATAL: AudioStream = preload("res://audio/sfx/hit_b_fatal.ogg")

const HIT_B_DELAY: float = 5.0/60

static var _map_battle_hp_bar_scene: PackedScene = \
		preload("res://controllers/attack controller/map_battle_info_display.tscn")

static func combat(attacker: Unit, defender: Unit) -> void:
	CursorController.disable()
	var attack_queue: Array[CombatStage] = [CombatStage.new(attacker, defender)]
	if defender.get_current_weapon() != null:
		var distance: int = \
				roundi(Utilities.get_tile_distance(attacker.position, defender.position))
		if distance in defender.get_current_weapon().get_range():
			attack_queue.append(CombatStage.new(defender, attacker))
	var attack_speed_check: bool = attacker.get_attack_speed() >= 5 + defender.get_attack_speed()
	if attacker.has_attribute(Skill.all_attributes.FOLLOW_UP) and attack_speed_check:
		attack_queue.append(CombatStage.new(attacker, defender))
	await _map_combat(attacker, defender, attack_queue)
	CursorController.enable()


static func _map_combat(attacker: Unit, defender: Unit, attack_queue: Array[CombatStage]) -> void:
	var hp_bar: HBoxContainer = _map_battle_hp_bar_scene.instantiate()
	hp_bar.attacker = attacker
	hp_bar.defender = defender
	MapController.get_ui().add_child(hp_bar)
	var attacker_animation: MapAttack = MapAttack.new(attacker, defender.position)
	attacker.get_parent().add_child(attacker_animation)
	var defender_animation: MapAttack = MapAttack.new(defender, attacker.position)
	defender.get_parent().add_child(defender_animation)
	attacker.visible = false
	defender.visible = false
	var get_timer: Callable = func() -> SceneTreeTimer:
		return hp_bar.get_tree().create_timer(DELAY)
	for combat_round: CombatStage in attack_queue:
		await get_timer.call().timeout
		var animation: MapAttack
		match combat_round.attacker:
			attacker: animation = attacker_animation
			defender: animation = defender_animation
		await _map_attack(combat_round.attacker, combat_round.defender, animation,
				combat_round.attack_type)
		if attacker.get_current_health() <= 0 or defender.get_current_health() <= 0:
			break
	await get_timer.call().timeout
	hp_bar.queue_free()
	if defender.get_current_health() <= 0:
		await _kill(defender, defender_animation)
	if attacker.get_current_health() > 0:
		attacker.visible = true
	else:
		await _kill(attacker, attacker_animation)
	attacker_animation.queue_free()
	if is_instance_valid(defender):
		defender.visible = true
	defender_animation.queue_free()


static func _map_attack(attacker: Unit, defender: Unit, attacker_animation: MapAttack,
		attack_type: attack_types) -> void:
	attacker_animation.play_animation()
	await attacker_animation.deal_damage
	var tween: Tween = defender.create_tween()
	tween.set_parallel()
	tween.tween_interval(0.1)
	if attack_type != attack_types.MISS:
		var hit_a: AudioStream = HIT_A_HEAVY
		var hit_b: AudioStream = HIT_B_HEAVY
		var damage: int = attacker.get_damage(defender)
		if attack_type == attack_types.CRIT:
			hit_a = HIT_A_CRIT
			damage = attacker.get_crit_damage(defender)
		var old_health: int = ceili(defender.get_current_health())
		var new_health: int = maxi(floori(old_health - damage), 0)
		if new_health <= 0:
			hit_b = HIT_B_FATAL
		var duration: float = (HEALTH_SCROLL_DURATION *
				float(old_health - new_health)/defender.get_stat(Unit.stats.HITPOINTS))
		tween.tween_method(defender.set_current_health.bind(false), old_health,
				new_health, duration)
		AudioPlayer.play_sound_effect(hit_a)
		await defender.get_tree().create_timer(HIT_B_DELAY).timeout
		await AudioPlayer.play_sound_effect(hit_b)
	if tween.is_running():
		await tween.finished
	attacker_animation.emit_signal("proceed")
	await attacker_animation.complete


static func _kill(unit: Unit, unit_animation: MapAttack) -> void:
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/death_fade.ogg"))
	var sync_fade: Tween = unit.create_tween()
	sync_fade.tween_property(unit_animation, "modulate:a", 0, Unit.FADE_AWAY_DURATION)
	sync_fade.play()
	await sync_fade.finished
	unit.queue_free()
	unit_animation.visible = false
	await unit_animation.get_tree().process_frame # Prevents visual bug


static func _calc(unit: Unit, other_unit: Unit) -> attack_types:
	if unit.get_hit_rate(other_unit) > randi_range(0, 99):
		if unit.get_crit_rate(other_unit) > randi_range(0, 99):
			print_debug("Crit")
			return attack_types.CRIT
		else:
			print_debug("Hit")
			return attack_types.HIT
	else:
		print_debug("Miss")
		return attack_types.MISS


class CombatStage extends RefCounted:
	var attacker: Unit
	var defender: Unit
	var attack_type: attack_types

	func _init(attacking_unit: Unit, defending_unit: Unit) -> void:
		attacker = attacking_unit
		defender = defending_unit
		attack_type = AttackController._calc(attacker, defender)
