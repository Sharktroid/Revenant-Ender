## A [Node] that displays the cursor's position.
extends PanelContainer


func _enter_tree() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_speed_scale(60)
	var icon: Sprite2D = $Sprite
	tween.tween_callback(icon.set_frame.bind(0))
	tween.tween_callback(icon.set_frame.bind(1)).set_delay(20)
	tween.tween_callback(icon.set_frame.bind(2)).set_delay(2)
	tween.tween_callback(icon.set_frame.bind(1)).set_delay(8)
	tween.tween_interval(2)


func _process(delta: float) -> void:
	visible = CursorController.cursor_visible
	var distance: float = position.distance_to(CursorController.screen_position) / 16
	position = position.move_toward(
		CursorController.screen_position, (maxf(1, distance) * 4) * 60 * delta
	)
