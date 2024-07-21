class_name MovementArrow
extends Sprite2D

const _END := Vector2i.MAX

var _prev: Vector2i
var _next: Vector2i


func _ready() -> void:
	if _prev == _END:
		match _next:
			Vector2i.LEFT:
				frame = 8
			Vector2i.RIGHT:
				frame = 0
			Vector2i.UP:
				frame = 7
			Vector2i.DOWN:
				frame = 1
	elif _next == _END:
		match _prev:
			Vector2i.LEFT:
				frame = 4
			Vector2i.RIGHT:
				frame = 12
			Vector2i.UP:
				frame = 5
			Vector2i.DOWN:
				frame = 11
	else:
		var sorted: Array[Vector2i] = [_prev, _next]
		sorted.sort()
		match sorted:
			[Vector2i.LEFT, Vector2i.RIGHT]:
				frame = 13
			[Vector2i.UP, Vector2i.DOWN]:
				frame = 6
			[Vector2i.LEFT, Vector2i.UP]:
				frame = 10
			[Vector2i.LEFT, Vector2i.DOWN]:
				frame = 3
			[Vector2i.DOWN, Vector2i.RIGHT]:
				frame = 2
			[Vector2i.UP, Vector2i.RIGHT]:
				frame = 9


static func instantiate(path: Array[Vector2i], index: int) -> MovementArrow:
	var scene := preload("res://maps/map_tiles/movement_arrow.tscn").instantiate() as MovementArrow
	scene._prev = (path[index - 1] - path[index]) / 16 if index > 0 else _END
	scene._next = (path[index + 1] - path[index]) / 16 if index < path.size() - 1 else _END
	scene.position = path[index]
	return scene
