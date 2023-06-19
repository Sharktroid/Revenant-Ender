extends Node
class_name GameController

var controller_type: String # Type of controller being used (keyboard, mouse, or controller)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		controller_type = "Mouse"
	elif event is InputEventKey:
		controller_type = "Keyboard"

	if event.is_action_pressed("fullscreen"):
		match get_window().mode:
			Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_WINDOWED
			Window.MODE_MAXIMIZED, Window.MODE_MINIMIZED, Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN

	if event.is_action_pressed("status"):
		print_stack()
