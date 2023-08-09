class_name MapAttack
extends Node2D

signal deal_damage
signal complete
signal arrived
signal proceed

var target_tile: Vector2i
var _combat_sprite: Node2D


func _init(connected_unit: Unit = null, targeted_tile: Vector2i = Vector2i(0, 16)) -> void:
	_combat_sprite = connected_unit.duplicate()
	target_tile = targeted_tile


func _ready() -> void:
	for child in _combat_sprite.get_children():
		(child as Node).queue_free()
	position = _combat_sprite.position
	_combat_sprite.position = Vector2i()
	_combat_sprite.remove_from_group("units")
	add_child(_combat_sprite)
	(_combat_sprite as Unit).sprite_animated = false
	(_combat_sprite as Unit).reset_map_anim()
	wait()


func play_animation() -> void:
	(_combat_sprite as Unit).sprite_animated = true
	var movement: Vector2 = (target_tile as Vector2 - position).normalized() * 4
	var angle: float = (target_tile as Vector2 - position).angle()
	var angle_adjusted = (angle * 4)/PI
	if angle_adjusted <= 1 and angle_adjusted >= -1:
		_combat_sprite.map_animation = Unit.animations.MOVING_LEFT
	elif angle_adjusted > -3 and angle_adjusted < -1:
		_combat_sprite.map_animation = Unit.animations.MOVING_UP
	elif angle_adjusted > 1 and angle_adjusted < 3:
		_combat_sprite.map_animation = Unit.animations.MOVING_DOWN
	else:
		_combat_sprite.map_animation = Unit.animations.MOVING_RIGHT
	await _move(movement)
	emit_signal("deal_damage")
	await proceed
	await _move(-movement)
	emit_signal("complete")
	(_combat_sprite as Unit).sprite_animated = false
	(_combat_sprite as Unit).reset_map_anim()


func wait() -> void:
	pass


func _move(movement: Vector2) -> void:
	var new_pos: Vector2 = position + movement
	while (position != new_pos):
		position = position.move_toward(new_pos, 1)
		await (get_tree() as SceneTree).physics_frame
	emit_signal("arrived")

