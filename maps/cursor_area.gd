extends Area2D

func _process(_delta: float) -> void:
	position = Vector2(CursorController.get_true_pos())
