extends SubViewportContainer


func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)


func _on_size_changed() -> void:
	var scale_vector: Vector2 = DisplayServer.window_get_size()/GenVars.get_screen_size()
	var scale: int = floor(min(scale_vector.x, scale_vector.y))
	($SubViewportContainer.material as ShaderMaterial).set_shader_parameter("pixel_scale", scale)
