class_name Flag
extends Sprite2D


static func instantiate(pos: Vector2i) -> Flag:
	const PACKED_SCENE: PackedScene = preload("res://maps/flag/flag.tscn")
	var scene := PACKED_SCENE.instantiate() as Flag
	scene.position = pos
	return scene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	const FRAME_DURATION: float = 16.0 / 60
	frame = floori(float(Time.get_ticks_msec()) / 1000 / FRAME_DURATION) % 3
