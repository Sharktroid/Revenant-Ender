class_name AttackHandler
extends RefCounted

enum {ATTACKER, DEFENDER}

const DELAY: float = 0.25
const HEALTH_SCROLL_DURATION: float = 0.5

static var _map_battle_hp_bar_scene: PackedScene = load("uid://dq4qai3phb4s7")

static func combat(attacker: Unit, defender: Unit) -> void:
	MapController.get_cursor().disable()
	var attack_queue: Array[int] = [ATTACKER]
	if defender.get_current_weapon() != null:
		var distance: int = roundi(GenFunc.get_tile_distance(attacker.position, defender.position))
		if distance in defender.get_current_weapon().get_range():
			attack_queue.append(DEFENDER)
	var attack_speed_check: bool = attacker.get_attack_speed() >= 5 + defender.get_attack_speed()
	if attacker.has_attribute(Skill.all_attributes.FOLLOW_UP) and attack_speed_check:
		attack_queue.append(ATTACKER)
	await _map_combat(attacker, defender, attack_queue)
	MapController.get_cursor().enable()


static func _map_combat(attacker: Unit, defender: Unit, attack_queue: Array[int]) -> void:
	var hp_bar = _map_battle_hp_bar_scene.instantiate()
	hp_bar.attacker = attacker
	hp_bar.defender = defender
	MapController.get_ui().add_child(hp_bar)
	var attacker_animation: MapAttack = MapAttack.new(attacker, defender.position)
	attacker.get_parent().add_child(attacker_animation)
	var defender_animation: MapAttack = MapAttack.new(defender, attacker.position)
	defender.get_parent().add_child(defender_animation)
	attacker.visible = false
	defender.visible = false
	for combat_round in attack_queue:
		var timer: SceneTreeTimer = attacker.get_tree().create_timer(DELAY)
		await timer.timeout
		match combat_round:
			ATTACKER: await _map_attack(attacker, defender, attacker_animation, defender_animation)
			DEFENDER: await _map_attack(defender, attacker, defender_animation, attacker_animation)
		if not(is_instance_valid(attacker) and is_instance_valid(defender)):
			break
	var timer: SceneTreeTimer = hp_bar.get_tree().create_timer(DELAY)
	await timer.timeout
	hp_bar.queue_free()
	if is_instance_valid(attacker):
		attacker.visible = true
	attacker_animation.queue_free()
	if is_instance_valid(defender):
		defender.visible = true
	defender_animation.queue_free()


static func _map_attack(attacker: Unit, defender: Unit, attacker_animation: MapAttack,
		defender_animation: MapAttack) -> void:
	attacker_animation.play_animation()
	await attacker_animation.deal_damage
	var old_health: int = ceili(defender.get_current_health())
	var new_health: int = maxi(floori(old_health - attacker.get_damage(defender)), 0)
	var max_health: int = defender.get_stat(Unit.stats.HITPOINTS)
	var current_health: float = old_health
	while defender.get_current_health() > new_health:
		current_health -= max_health * GenVars.get_frame_delta() / HEALTH_SCROLL_DURATION
		current_health = maxf(current_health, new_health)
		defender.set_current_health(roundi(current_health))
		await defender.get_tree().process_frame
	if defender.dead:
		var fade = FadeOut.new(20.0/60)
		defender_animation.add_child(fade)
		await fade.complete
		defender.queue_free()
	await attacker_animation.get_tree().process_frame
	attacker_animation.emit_signal("proceed")
	await attacker_animation.complete
