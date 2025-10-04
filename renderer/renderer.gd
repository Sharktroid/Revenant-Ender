extends SubViewportContainer


func _enter_tree() -> void:
	# Placeholder
	MapController.map = $SubViewport/TestMapB as Map
	_on_size_changed.call_deferred()
	get_viewport().size_changed.connect(_on_size_changed)


func _ready() -> void:
	if Utilities.is_running_project():
		(%FPSDisplay as HBoxContainer).visible = Options.SHOW_FPS.value
	else:
		%DebugUI.add_child(preload("res://renderer/crash_handler/crash_handler.tscn").instantiate())


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


func get_pixel_scale() -> int:
	var scale_vector: Vector2 = DisplayServer.window_get_size() / Utilities.get_screen_size()
	return floori(minf(scale_vector.x, scale_vector.y))


func _on_size_changed() -> void:
	(material as ShaderMaterial).set_shader_parameter("pixel_scale", get_pixel_scale())
