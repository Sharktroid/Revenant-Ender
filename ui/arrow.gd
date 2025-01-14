extends Sprite2D


func _enter_tree() -> void:
	var tween: Tween = create_tween()
	tween.set_speed_scale(60)
	var add_frame: Callable = func() -> void:
		frame += 1
		frame %= 5
	tween.tween_callback(add_frame).set_delay(8)
	tween.set_loops()
