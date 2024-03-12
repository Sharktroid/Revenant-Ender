extends SubViewportContainer


func _enter_tree() -> void:
	# Placeholder
	MapController.map = $"SubViewport/Test Map B" as Map
	_on_size_changed.call_deferred()
	get_viewport().size_changed.connect(_on_size_changed)


func _on_size_changed() -> void:
	var scale_vector: Vector2 = DisplayServer.window_get_size()/Utilities.get_screen_size()
	(material as ShaderMaterial).set_shader_parameter("pixel_scale",
			floori(minf(scale_vector.x, scale_vector.y)))
