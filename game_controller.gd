extends Node
class_name GameController

var controller_type: String # Type of controller being used (keyboard, mouse, or controller)
var _scaling: int = 0


func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)


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


func get_scaling() -> int:
	if _scaling == 0:
		set_scaling(get_viewport().size)
	return _scaling


func set_scaling(size: Vector2i) -> void:
	var dividend: Vector2 = (size as Vector2)/(GenVars.default_screen_size as Vector2)
	_scaling = ceil(max(dividend.x, dividend.y))
	GenVars.get_level_controller().set_scaling(_scaling)


func _on_size_changed() -> void:
	set_scaling(get_viewport().size)
	GenVars.get_map_camera().update_offset()
