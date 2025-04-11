class_name SingleAxisInputController
extends TwoAxisInputController


func _init(
	on_axis_moved: Callable,
	x_axis_negative: StringName,
	x_axis_positive: StringName,
	press_delay: float = 0.25,
	hold_delay: float = 1.0 / 15
) -> void:
	super(on_axis_moved, x_axis_negative, x_axis_positive, &"", &"", press_delay, hold_delay)
	_on_axis_moved = func(vector: Vector2) -> void: await on_axis_moved.call(vector.x)


func _get_vector() -> Vector2:
	if can_process():
		return Vector2(Input.get_axis(_x_axis_negative, _x_axis_positive), 0)
	return super()
