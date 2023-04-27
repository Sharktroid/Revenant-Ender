extends Area2D

func _process(_delta):
	position = GenVars.get_cursor().get_true_pos() as Vector2
