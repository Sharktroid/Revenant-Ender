extends Sprite2D


func _init() -> void:
	_update_frame()


func _process(_delta: float) -> void:
	_update_frame()


func _update_frame() -> void:
	frame = floori(float(Engine.get_physics_frames())/3) % 16
