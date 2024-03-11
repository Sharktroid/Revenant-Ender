extends Node

const _RECIEVER = preload("res://controllers/game_controller/recieve_input_node.gd")

enum controller_types {MOUSE, KEYBOARD}
## Type of controller being used (keyboard, mouse, or controller)
var controller_type: controller_types

var _input_stack: Array[Node] = []


func _init() -> void:
	seed(0) # Sets RNG to be deterministic
	controller_type = controller_types.MOUSE


func _physics_process(_delta: float) -> void:
	randi() # Burns a random number every frame


func _input(event: InputEvent) -> void:
	if ((controller_type != controller_types.MOUSE) and
			(event is InputEventMouseButton or event is InputEventMouseMotion)):
		controller_type = controller_types.MOUSE
	elif event is InputEventKey:
		controller_type = controller_types.KEYBOARD
	get_current_input_node().receive_input(event)

	if event.is_action_pressed("fullscreen"):
		match get_window().mode:
			Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_WINDOWED
			Window.MODE_MAXIMIZED, Window.MODE_MINIMIZED, Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN


func add_to_input_stack(node: Node) -> void:
	_input_stack.append(node)


func remove_from_input_stack() -> void:
	_input_stack.remove_at(_input_stack.size() - 1)


func get_current_input_node() -> _RECIEVER:
	while not is_instance_valid(_input_stack[-1]):
		remove_from_input_stack()
	return _input_stack[-1]


func get_root() -> Viewport:
	const PATH: String = "SubViewportContainer/SubViewport"
	if get_viewport() and get_viewport().has_node(PATH):
		return get_viewport().get_node(PATH) as Viewport
	else:
		return Window.new()
