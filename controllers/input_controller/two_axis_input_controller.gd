class_name TwoAxisInputController
extends Node

enum States { RELEASED, PRESSED, HELD }

const _BUFFER_TIMER: float = 0.05

var _on_axis_moved: Callable
var _x_axis_negative: StringName
var _x_axis_positive: StringName
var _y_axis_negative: StringName
var _y_axis_positive: StringName
var _state: States
var _press_delay: float
var _hold_delay: float
var _press_timer: SceneTreeTimer


func _init(
	on_axis_moved: Callable,
	x_axis_negative: StringName,
	x_axis_positive: StringName,
	y_axis_negative: StringName,
	y_axis_positive: StringName,
	press_delay: float = 0.25,
	hold_delay: float = 1.0 / 15
) -> void:
	_on_axis_moved = on_axis_moved
	_x_axis_negative = x_axis_negative
	_x_axis_positive = x_axis_positive
	_y_axis_negative = y_axis_negative
	_y_axis_positive = y_axis_positive
	_press_delay = press_delay
	_hold_delay = hold_delay


func _physics_process(_delta: float) -> void:
	if _get_vector():
		if _state == States.RELEASED:
			_state = States.PRESSED
			await _repeater(_get_vector())
	elif _state == States.HELD:
		_state = States.RELEASED
		_press_timer.time_left = 0


func _repeater(vector: Vector2) -> void:
	await _on_axis_moved.call(vector)
	_state = States.HELD
	_press_timer = get_tree().create_timer(_press_delay)
	await _press_timer.timeout
	while _state == States.HELD:
		await _on_axis_moved.call(_get_vector())
		await get_tree().create_timer(_hold_delay).timeout


func _get_vector() -> Vector2:
	if can_process():
		return Input.get_vector(
			_x_axis_negative, _x_axis_positive, _y_axis_negative, _y_axis_positive
		)
	return Vector2.ZERO
