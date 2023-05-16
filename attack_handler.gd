class_name AttackHandler
extends RefCounted


static func combat(attacker: Unit, defender: Unit) -> void:
	await map_combat(attacker, defender)


static func map_combat(attacker: Unit, defender: Unit) -> void:
	var attacker_animation: MapAttack = MapAttack.new(attacker, defender.position)
	attacker.get_parent().add_child(attacker_animation)
	var defender_animation: MapAttack = MapAttack.new(defender, attacker.position)
	defender.get_parent().add_child(defender_animation)
	attacker.visible = false
	defender.visible = false
	await _map_attack(attacker, defender, attacker_animation)
	attacker.visible = true
	attacker_animation.queue_free()
	defender.visible = true
	defender_animation.queue_free()


static func _map_attack(attacker: Unit, defender: Unit, attacker_animation: MapAttack) -> void:
	attacker_animation.play_animation()
	await attacker_animation.deal_damage
	defender.add_current_health(-attacker.get_damage(defender))
	attacker_animation.emit_signal("proceed")
	await attacker_animation.complete
