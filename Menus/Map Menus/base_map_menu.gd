class_name MapMenu
extends Control

enum types {SACRED_STONES, BINDING_BLADE}

#var _font_node: PackedScene = preload("res://text.tscn")
var items: Array[String]
#var _index: int
#var _max_length: int
var _start_offset: int
var _end_offset: int


func _init():
	items = get_items()


func _enter_tree() -> void:
#	var path: String = "res://UI/Binding Blade/"
	_start_offset = 4
	_end_offset = 5
#	$"Base Menu Tiles/MenuTopOverlay".visible = false
#	$"Base Menu Tiles/MenuTopLeft".texture = load(path + "menu_top_left.png")
#	$"Base Menu Tiles/MenuTopCenter".texture = load(path + "menu_top_mid.png")
#	$"Base Menu Tiles/MenuTopRight".texture = load(path + "menu_top_right.png")
#	$"Base Menu Tiles/MenuMiddleItemLeft".texture = load(path + "menu_middle_item_left.png")
#	$"Base Menu Tiles/MenuMiddleItemCenter".texture = load(path + "menu_middle_item_mid.png")
#	$"Base Menu Tiles/MenuMiddleItemRight".texture = load(path + "menu_middle_item_right.png")
#	$"Base Menu Tiles/MenuMiddleNoItemLeft".texture = load(path + "menu_middle_no_item_left.png")
#	$"Base Menu Tiles/MenuMiddleNoItemCenter".texture = load(path + "menu_middle_no_item_mid.png")
#	$"Base Menu Tiles/MenuMiddleNoItemRight".texture = load(path + "menu_middle_no_item_right.png")
#	$"Base Menu Tiles/MenuBottomLeft".texture = load(path + "menu_bottom_left.png")
#	$"Base Menu Tiles/MenuBottomCenter".texture = load(path + "menu_bottom_mid.png")
#	$"Base Menu Tiles/MenuBottomRight".texture = load(path + "menu_bottom_right.png")


func _ready() -> void:
	var new_size = Vector2()
#	$"VBoxContainer/Center Container/Center Panel/Items/Button".grab_focus()
	for item in items:
		var button: Button = $"Base Button".duplicate()
		button.text = item
#		button.pressed.connect(_on_button_pressed)
#		butt
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		new_size.y += 16
		$Items.add_child(button)
		new_size.x = max(new_size.x, button.size.x * scale.x + 4)
	$Items.size = new_size
	size = $Items.size + Vector2(9, 9)
	$"Base Button".queue_free()
#	create_menu()

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
#	print_debug(button.text)
	var index = items.find(button.text)
	items = get_items()
	button.text = items[index]
