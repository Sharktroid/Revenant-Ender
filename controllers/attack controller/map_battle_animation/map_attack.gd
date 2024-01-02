class_name MapAttack
extends Node2D

signal deal_damage
signal complete
signal arrived
signal proceed

var target_tile: Vector2i
var _combat_sprite: Unit


func _init(connected_unit: Unit = null, targeted_tile: Vector2i = Vector2i(0, 16)) -> void:
	_combat_sprite = connected_unit.duplicate()
	target_tile = targeted_tile


func _ready() -> void:
	for child in _combat_sprite.get_children():
		if not child is AnimationPlayer:
			child.queue_free()
	position = _combat_sprite.position
	_combat_sprite.position = Vector2i()
	_combat_sprite.remove_from_group("units")
	add_child(_combat_sprite)
	_combat_sprite.sprite_animated = false

	var angle: float = (Vector2(target_tile) - position).angle()
	var angle_adjusted = (angle * 4)/PI
	var animation: Unit.animations
	if angle_adjusted <= 1 and angle_adjusted >= -1:
		animation = Unit.animations.MOVING_RIGHT
	elif angle_adjusted > -3 and angle_adjusted < -1:
		animation = Unit.animations.MOVING_UP
	elif angle_adjusted > 1 and angle_adjusted < 3:
		animation = Unit.animations.MOVING_DOWN
	else:
		animation = Unit.animations.MOVING_LEFT
	_combat_sprite.set_animation(animation)


func play_animation() -> void:
	var movement: Vector2 = (Vector2(target_tile) - position).normalized() * 4
	_combat_sprite.sprite_animated = true
	await _move(movement)
	emit_signal("deal_damage")
	await proceed
	await _move(-movement)
	emit_signal("complete")
	_combat_sprite.sprite_animated = false


func _move(movement: Vector2) -> void:
	var end_pos: Vector2 = position + movement
	var tween: Tween = create_tween()
	tween.tween_method(func(new_pos: Vector2): position = new_pos.round(),
			position, end_pos, 8.0/60)
	await tween.finished
	emit_signal("arrived")

