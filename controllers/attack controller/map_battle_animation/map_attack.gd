## Class that displays attack animations on the [Map].
class_name MapAttack
extends Node2D

## Emitted when the animation completes.
signal completed
## Emitted when the animation has arrived to the destination.
signal arrived

## The tile where the enemy unit is located.
var _target_tile: Vector2i
## The unit that is being displayed by the animation.
var _combat_sprite: UnitSprite
var _running: bool = false


func _init(connected_unit: Unit = null, targeted_tile := Vector2i(0, 16)) -> void:
	_combat_sprite = connected_unit.get_sprite()
	_target_tile = targeted_tile
	position = connected_unit.position
	_combat_sprite.position = Vector2i()
	add_child(_combat_sprite)
	await _combat_sprite.ready
	_combat_sprite.sprite_animated = false
	_combat_sprite.set_animation(
		_get_animation((Vector2(_target_tile) - position).angle() * 4 / PI)
	)
	#_combat_sprite.set_animation(UnitSprite.Animations.MOVING_LEFT)
	#print_debug((Vector2(_target_tile) - position).angle() * 4 / PI)


## @experimental
## Plays the map animation.
func play_animation() -> void:
	_running = true
	var movement: Vector2 = (Vector2(_target_tile) - position).normalized() * 4
	_combat_sprite.sprite_animated = true
	await _move(movement)
	arrived.emit()
	await _move(-movement)
	completed.emit()
	_combat_sprite.sprite_animated = false
	_running = false


## Sets the animation's alpha value.
func set_alpha(alpha: float) -> void:
	_combat_sprite.modulate.a = alpha


## Plays the animation for when a unit it hit by a non-critical hit
func damage_animation() -> void:
	var white_tween: Tween = create_tween()
	white_tween.set_speed_scale(60)
	white_tween.tween_method(_set_white_percentage, 1.0, 0.0, 29)
	var starting_x: int = roundi(position.x)
	var oscillate_tween: Tween = create_tween()
	oscillate_tween.set_speed_scale(60)
	oscillate_tween.set_loops(8)
	oscillate_tween.tween_callback(func() -> void: position.x = starting_x + 1).set_delay(1)
	oscillate_tween.tween_callback(func() -> void: position.x = starting_x - 1).set_delay(1)
	await oscillate_tween.finished
	position.x = starting_x
	await white_tween.finished


## Plays the animation for when a unit it hit by a critical hit
func crit_damage_animation() -> void:
	var oscillate_tween: Tween = create_tween()
	oscillate_tween.set_speed_scale(60)
	oscillate_tween.tween_callback(_set_white_percentage.bind(1))
	oscillate_tween.tween_callback(_set_white_percentage.bind(0)).set_delay(2)
	oscillate_tween.tween_interval(2)
	await oscillate_tween.finished
	await damage_animation()


## Returns true if the animation is playing.
func is_running() -> bool:
	return _running


## Moves the sprite to show they're attacking.
func _move(movement: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.set_speed_scale(60)
	tween.tween_method(
		func(new_pos: Vector2) -> void: position = new_pos.round(), position, position + movement, 8
	)
	await tween.finished


## Sets the sprite's shader white percentage
func _set_white_percentage(percentage: float) -> void:
	(_combat_sprite.material as ShaderMaterial).set_shader_parameter("white_percentage", percentage)


func _get_animation(angle: float) -> Unit.Animations:
	if angle <= 1 and angle >= -1:
		return Unit.Animations.MOVING_RIGHT
	elif angle > -3 and angle < -1:
		return Unit.Animations.MOVING_UP
	elif angle > 1 and angle < 3:
		return Unit.Animations.MOVING_DOWN
	else:
		return Unit.Animations.MOVING_LEFT
