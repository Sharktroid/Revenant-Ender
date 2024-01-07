extends SubViewportContainer


func _ready() -> void:
	_on_size_changed()
	get_viewport().size_changed.connect(_on_size_changed)


func _on_size_changed() -> void:
	var scale_vector: Vector2 = DisplayServer.window_get_size()/Utilities.get_screen_size()
	var pixel_scale: int = floori(minf(scale_vector.x, scale_vector.y))
	material.set_shader_parameter("pixel_scale", pixel_scale)
