class_name MapMenu
extends Control

enum types {SACRED_STONES, BINDING_BLADE}

var items: Array[String]
var _start_offset: int
var _end_offset: int


func _init():
	items = get_items()


func _enter_tree() -> void:
	_start_offset = 4
	_end_offset = 5


func _ready() -> void:
	var new_size = Vector2()
	for item in items:
		var button: Button = $"Base Button".duplicate()
		button.text = item
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		new_size.y += 16
		$Items.add_child(button)
		new_size.x = max(new_size.x, button.size.x * scale.x + 4)
	$Items.size = new_size
	size = $Items.size + Vector2(9, 9)
	$"Base Button".queue_free()

func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_up"):
#		_move_selection(_index - 1)
#
#	elif event.is_action_pressed("ui_down"):
#		_move_selection(_index + 1)
#
#	if event.is_action_pressed("ui_accept"):
#		select_item()

	if event.is_action_pressed("ui_cancel"):
		close()


func get_items() -> Array[String]:
	return []


func close() -> void:
	# Closes the menu
	queue_free()


func set_active(is_active: bool) -> void:
	# Sets whether this menu is currently active.
	set_process_input(is_active)
	visible = is_active


func _on_button_pressed(button: Button) -> void:
	var index: int = items.find(button.text)
	items = get_items()
	button.text = items[index]
