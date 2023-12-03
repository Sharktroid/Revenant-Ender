extends Node2D

var color := Color.RED


func _init():
	color.a = 0.5


func _draw():
	draw_rect(Rect2(1.0, 1.0, 3.0, 3.0), color)
	draw_rect(Rect2(5.5, 1.5, 2.0, 2.0), color, false, 1.0)
	draw_rect(Rect2(9.0, 1.0, 5.0, 5.0), color)
	draw_rect(Rect2(16.0, 2.0, 3.0, 3.0), color, false, 2.0)
