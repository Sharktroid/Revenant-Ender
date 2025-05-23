## Autoload that manages global functions and variables.
extends Node

## The possible types of controller that can be used.
enum ControllerTypes { MOUSE, KEYBOARD }

## Type of controller currently being used.
var controller_type: ControllerTypes


func _init() -> void:
	seed(0)  # Sets RNG to be deterministic
	controller_type = ControllerTypes.MOUSE


func _ready() -> void:
	if get_root():
		_update_fps_display()
		Options.SHOW_FPS.value_updated.connect(_update_fps_display)


func _physics_process(_delta: float) -> void:
	randi()  # Burns a random number every frame


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		controller_type = ControllerTypes.MOUSE
	elif event is InputEventKey:
		controller_type = ControllerTypes.KEYBOARD
	elif (
		event is InputEventJoypadButton
		or (event is InputEventJoypadMotion and (event as InputEventJoypadMotion).axis_value >= 0.1)
	):
		controller_type = ControllerTypes.KEYBOARD

	if event.is_action_pressed("fullscreen"):
		match get_window().mode:
			Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_WINDOWED
			Window.MODE_MAXIMIZED, Window.MODE_MINIMIZED, Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN


## Gets the [SubViewport] that all nodes originate in.
func get_root() -> Node:
	const PATH: NodePath = ^"SubViewportContainer/SubViewport"
	if get_viewport() and get_viewport().has_node(PATH):
		return get_viewport().get_node(PATH) as Node
	return null


# Toggles the FPS display depending on the config
func _update_fps_display() -> void:
	(get_root().get_node("%FPSDisplay") as HBoxContainer).visible = (Options.SHOW_FPS.value)
