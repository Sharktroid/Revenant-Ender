extends Node

enum controller_types {MOUSE, KEYBOARD}

var controller_type: controller_types # Type of controller being used (keyboard, mouse, or controller)


func _init() -> void:
	seed(0) # Sets RNG to be deterministic
	controller_type = controller_types.MOUSE


func _physics_process(_delta: float) -> void:
	randi() # Burns a random number every frame


func _input(event: InputEvent) -> void:
	if ((controller_type != controller_types.MOUSE) and
			(event is InputEventMouseButton or event is InputEventMouseMotion)):
		controller_type = controller_types.MOUSE
		Input.parse_input_event(event)
	elif event is InputEventKey:
		controller_type = controller_types.KEYBOARD

	if event.is_action_pressed("fullscreen"):
		match get_window().mode:
			Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_WINDOWED
			Window.MODE_MAXIMIZED, Window.MODE_MINIMIZED, Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	#elif event.is_action_pressed("debug"):
		#print_debug(CursorController.get_true_pos())


func get_root() -> Viewport:
	if get_viewport() and get_viewport().has_node("SubViewportContainer/SubViewport"):
		return get_viewport().get_node("SubViewportContainer/SubViewport")
	else:
		return Window.new()
