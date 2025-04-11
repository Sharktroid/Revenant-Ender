class_name ScrollAxisInputController
extends SingleAxisInputController

var _scroll_direction: int


func _init(
	on_axis_moved: Callable,
	x_axis_negative: StringName,
	x_axis_positive: StringName,
	scroll_direction: int,
	press_delay: float = 0.25,
	hold_delay: float = 1.0 / 15,
) -> void:
	super(on_axis_moved, x_axis_negative, x_axis_positive, press_delay, hold_delay)
	_on_axis_moved = func(vector: Vector2) -> void: await on_axis_moved.call(vector.x)
	_scroll_direction = sign(scroll_direction)


func _input(event: InputEvent) -> void:
	if _state == States.RELEASED:
		if event.is_action_pressed(&"scroll_up"):
			_state = States.PRESSED
			await _on_axis_moved.call(Vector2(-_scroll_direction, 0))
			_state = States.RELEASED
		elif event.is_action_pressed(&"scroll_down"):
			_state = States.PRESSED
			await _on_axis_moved.call(Vector2(_scroll_direction, 0))
			_state = States.RELEASED
