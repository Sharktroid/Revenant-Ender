class_name MapAttack
extends Node2D

signal deal_damage
signal complete
signal arrived
signal proceed

var new_pos: Vector2i
var target_tile: Vector2i
var _unit: Unit
var _combat_sprite: Unit


func _init(connected_unit: Unit = null, targeted_tile: Vector2i = Vector2i(0, 16)) -> void:
	_unit = connected_unit
	target_tile = targeted_tile


func _ready() -> void:
	_combat_sprite = _unit.duplicate()
	for child in _combat_sprite.get_children():
		(child as Node).queue_free()
	_combat_sprite.position = Vector2i()
	_combat_sprite.remove_from_group("units")
	add_child(_combat_sprite)
	position = _unit.position
	new_pos = position
	(_combat_sprite as Unit).sprite_animated = false
	(_combat_sprite as Unit).reset_map_anim()
	wait()


func _physics_process(_delta: float) -> void:
	position = position.move_toward(new_pos, 1)


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
	await _move(-movement)
	emit_signal("complete")
	(_combat_sprite as Unit).sprite_animated = false
	(_combat_sprite as Unit).reset_map_anim()


func wait() -> void:
	pass


func _move(pos: Vector2i) -> void:
	new_pos += pos
	while (position != (new_pos as Vector2)):
		await (get_tree() as SceneTree).process_frame
	emit_signal("arrived")

