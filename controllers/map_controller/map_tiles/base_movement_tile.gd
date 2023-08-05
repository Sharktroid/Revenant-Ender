extends Sprite2D


func _ready() -> void:
	_update_frame()


func _process(_delta: float) -> void:
	_update_frame()


func _update_frame() -> void:
	frame = int(floor(float(get_tree().get_frame())/3)) % 16
