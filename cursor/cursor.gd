## A [Node] that displays the cursor's position.
extends PanelContainer

var _animation_tween: Tween


func _enter_tree() -> void:
	_animation_tween = create_tween()
	_animation_tween.set_loops()
	_animation_tween.set_speed_scale(60)
	var icon: Sprite2D = $Sprite
	_animation_tween.tween_callback(icon.set_frame.bind(0))
	_animation_tween.tween_callback(icon.set_frame.bind(1)).set_delay(20)
	_animation_tween.tween_callback(icon.set_frame.bind(2)).set_delay(2)
	_animation_tween.tween_callback(icon.set_frame.bind(1)).set_delay(8)
	_animation_tween.tween_interval(2)

	var on_visibility_changed: Callable = func() -> void:
		if visible:
			_animation_tween.play()
		else:
			_animation_tween.stop()
	visibility_changed.connect(on_visibility_changed)

	var cursor_moved: Callable = func() -> void:
		if GameController.controller_type == GameController.ControllerTypes.MOUSE:
			_animation_tween.stop()
			_animation_tween.play()
	CursorController.moved.connect(cursor_moved)


func _process(delta: float) -> void:
	visible = _should_display_cursor()
	position = _get_position(delta)


func _should_display_cursor() -> bool:
	if GameController.controller_type == GameController.ControllerTypes.MOUSE:
		return CursorController.cursor_visible and CursorController.get_hovered_unit()
	else:
		return CursorController.cursor_visible


func _get_position(delta: float) -> Vector2:
	if GameController.controller_type == GameController.ControllerTypes.MOUSE:
		return CursorController.screen_position
	else:
		return position.move_toward(
			CursorController.screen_position,
			(maxf(1, position.distance_to(CursorController.screen_position) / 16) * 4) * 60 * delta
		)
