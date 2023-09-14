extends Area2D

func _process(_delta):
	position = Vector2(MapController.get_cursor().get_true_pos())
