class_name MapAttack
extends Node2D

signal completed
signal arrived
signal damage_dealt

var target_tile: Vector2i
var _combat_sprite: Unit


func _init(connected_unit: Unit = null, targeted_tile := Vector2i(0, 16)) -> void:
	_combat_sprite = connected_unit.duplicate() as Unit
	target_tile = targeted_tile
	for child: Node in _combat_sprite.get_children():
		if child is not AnimationPlayer:
			child.queue_free()
	position = _combat_sprite.position
	_combat_sprite.position = Vector2i()
	_combat_sprite.remove_from_group("units")
	add_child(_combat_sprite)
	await _combat_sprite.tree_entered
	_combat_sprite.sprite_animated = false
	_combat_sprite.flip_h = false
	var angle: float = ((Vector2(target_tile) - position).angle() * 4) / PI
	_combat_sprite.set_animation.call_deferred(
		(
			Unit.Animations.MOVING_RIGHT
			if angle <= 1 and angle >= -1
			else (
				Unit.Animations.MOVING_UP
				if angle > -3 and angle < -1
				else (
					Unit.Animations.MOVING_DOWN
					if angle > 1 and angle < 3
					else Unit.Animations.MOVING_LEFT
				)
			)
		)
	)


func play_animation() -> void:
	var movement: Vector2 = (Vector2(target_tile) - position).normalized() * 4
	_combat_sprite.sprite_animated = true
	await _move(movement)
	arrived.emit()
	await damage_dealt
	await _move(-movement)
	completed.emit()
	_combat_sprite.sprite_animated = false


func set_alpha(alpha: float) -> void:
	_combat_sprite.modulate.a = alpha
	_combat_sprite.update_shader()


func _move(movement: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.set_speed_scale(60)
	tween.tween_method(
		func(new_pos: Vector2) -> void: position = new_pos.round(), position, position + movement, 8
	)
	await tween.finished
