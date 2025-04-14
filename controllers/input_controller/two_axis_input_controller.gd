class_name TwoAxisInputController
extends Node

enum States { RELEASED, PRESSED, HELD }

const _BUFFER_LENGTH: float = 0.05

var _on_axis_moved: Callable
var _x_axis_negative: StringName
var _x_axis_positive: StringName
var _y_axis_negative: StringName
var _y_axis_positive: StringName
var _state: States
var _press_delay: float
var _hold_delay: float
var _press_timer: SceneTreeTimer
var _thread_count: int = 0
var _locked: bool
var _buffer: Vector2
var _buffer_timer: SceneTreeTimer
var _pivot_timer: SceneTreeTimer


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


func _ready() -> void:
	_buffer_timer = get_tree().create_timer(1)
	_pivot_timer = get_tree().create_timer(1)



func _physics_process(_delta: float) -> void:
	if _get_vector():
		if _state == States.RELEASED:
			if _locked:
				_buffer_timer.time_left = 0 # End a previous buffer timer.
				_buffer = _get_vector()
				# The buffer should only be created if the input is made within the buffer length.
				# Due to the nature of callables, this requires a bit of a trick.
				_buffer_timer = get_tree().create_timer(_BUFFER_LENGTH)
				await _buffer_timer.timeout
				_buffer = Vector2.ZERO
			else:
				assert(not _press_timer or _press_timer.time_left == 0)
				_state = States.PRESSED
				await _repeater(_get_vector())
				# If there is a buffer, we need to process it.
				while _buffer:
					await _repeater(_buffer)
	elif _state == States.HELD and _pivot_timer.time_left == 0:
		_pivot_timer = get_tree().create_timer(_BUFFER_LENGTH)
		await _pivot_timer.timeout
		# The button will only be released if there is still no input.
		# This is to prevent the input being released if the player is switching directions
		if _get_vector() == Vector2.ZERO:
			_state = States.RELEASED


func _repeater(vector: Vector2) -> void:
	_locked = true
	_thread_count += 1
	assert(_thread_count <= 1)
	_buffer = Vector2.ZERO
	await _on_axis_moved.call(vector)
	_state = States.HELD
	_press_timer = get_tree().create_timer(_press_delay)
	await _press_timer.timeout
	while _state == States.HELD:
		await _on_axis_moved.call(_get_vector())
		_press_timer = get_tree().create_timer(_hold_delay)
		await _press_timer.timeout
	_thread_count -= 1
	_locked = false


func _get_vector() -> Vector2:
	if can_process():
		return Input.get_vector(
			_x_axis_negative, _x_axis_positive, _y_axis_negative, _y_axis_positive
		)
	return Vector2.ZERO
