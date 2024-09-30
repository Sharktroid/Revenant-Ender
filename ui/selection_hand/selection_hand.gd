extends Sprite2D


func _ready() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_speed_scale(60)
	tween.tween_interval(7)
	tween.tween_property(self, "offset:x", -11, 9)
	tween.tween_interval(7)
	tween.tween_property(self, "offset:x", -15, 9)
