extends SubViewportContainer


func _enter_tree() -> void:
	# Placeholder
	MapController.map = $SubViewport/TestMapB as Map
	_on_size_changed.call_deferred()
	get_viewport().size_changed.connect(_on_size_changed)


func _ready() -> void:
	if Utilities.is_running_project():
		(%FPSDisplay as HBoxContainer).visible = DebugConfig.SHOW_FPS.value


func _process(delta: float) -> void:
	(%AverageProcessFrameLabel as Label).text = str(Engine.get_frames_per_second())
	(%ImmediateProcessFrameLabel as Label).text = str(roundi(1 / delta))


func _physics_process(delta: float) -> void:
	(%PhysicFrameLabel as Label).text = str(roundi(1 / delta))


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			get_tree().paused = true
		NOTIFICATION_APPLICATION_FOCUS_IN:
			get_tree().paused = false


func _on_size_changed() -> void:
	var scale_vector: Vector2 = DisplayServer.window_get_size() / Utilities.get_screen_size()
	(material as ShaderMaterial).set_shader_parameter(
		"pixel_scale", floori(minf(scale_vector.x, scale_vector.y))
	)
