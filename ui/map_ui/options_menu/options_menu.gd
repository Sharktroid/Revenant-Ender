extends Control

var _current_index: int = 0:
	set(value):
		_current_index = posmod(value, _option_count)
		if _current_index == 0:
			_top_index = 0
		elif _current_index == _option_count - 1:
			_top_index = _option_count - _displayed_item_count
		elif get_relative_index() == _displayed_item_count:
			_top_index += 1
		elif get_relative_index() == 0:
			_top_index -= 1
		_hand_sprite.position.y = _hand_starting_y + get_relative_index() * 16
var _top_index: int = 0
var _displayed_item_count: int

@onready var _scroll_container := %ScrollContainer as ScrollContainer
@onready var _option_count: int = (%OptionsList as VBoxContainer).get_child_count()
@onready var _hand_sprite := $Hand as Sprite2D
@onready var _hand_starting_y: int = roundi(_hand_sprite.position.y)


func _ready() -> void:
	await get_tree().process_frame
	_displayed_item_count = floori(_scroll_container.size.y / 16)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up", true):
		_current_index -= 1
	if event.is_action_pressed("down", true):
		_current_index += 1


func _process(_delta: float) -> void:
	_scroll_container.scroll_vertical = _top_index * 16


func get_relative_index() -> int:
	return _current_index - _top_index
