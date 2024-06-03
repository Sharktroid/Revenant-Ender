extends Sprite2D


func _enter_tree() -> void:
	var tween: Tween = create_tween()
	tween.set_speed_scale(60)
	tween.tween_callback(_add_frame).set_delay(8)


func _add_frame() -> void:
	frame += 1
	frame %= 5
