extends Sprite2D


func _physics_process(_delta: float) -> void:
	if Engine.get_physics_frames() % 8 == 0:
		_add_frame()

func _add_frame() -> void:
	if frame == 5:
		frame = 0
	else:
		frame += 1
