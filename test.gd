extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Line2D.points = [Vector2i(0, 0), Vector2i(0, 16)]
	$Line2D.points = [Vector2i(0, 16), Vector2i(16, 16)]
	$Line2D.points = [Vector2i(16, 16), Vector2i(16, 0)]
	$Line2D.points = [Vector2i(16, 0), Vector2i(0, 0)]
