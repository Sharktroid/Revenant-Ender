extends CanvasLayer


func _ready() -> void:
	print(get_size())


func get_size() -> Vector2:
	return Vector2(224, 240)
