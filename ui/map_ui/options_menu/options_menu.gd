extends Control

const _OPTION := preload("res://ui/map_ui/options_menu/option.gd")
var _options: Array[_OPTION] = [
	_OPTION.new("Animations", ["Map", "Off"]),
	_OPTION.new("Text Speed", ["Slow", "Medium", "Fast", "Max"], 1),
]

var _settings_indices: Array[int]
var _current_index: int = 0:
	set(value):
		_current_index = posmod(value, _option_count)
		if _current_index == 0:
			_top_index = 0
		elif _current_index == _option_count - 1:
			_top_index = _option_count - _displayed_item_count
		elif _get_relative_index() == _displayed_item_count:
			_top_index += 1
		elif _get_relative_index() == 0:
			_top_index -= 1
		_hand_sprite.position.y = _hand_starting_y + _get_relative_index() * 16
var _top_index: int = 0
var _displayed_item_count: int = _options.size()

@onready var _scroll_container := %ScrollContainer as ScrollContainer
@onready var _option_count: int = _options.size()
@onready var _hand_sprite := $Hand as Sprite2D
@onready var _hand_starting_y: int = roundi(_hand_sprite.position.y)


func _ready() -> void:
	for option: _OPTION in _options:
		var icon_rect := TextureRect.new()
		icon_rect.texture = option.get_icon()
		var icon_center := CenterContainer.new()
		icon_center.custom_minimum_size = Vector2i(16, 16)
		icon_center.add_child(icon_rect)
		%IconsList.add_child(icon_center)

		var name_label := Label.new()
		name_label.text = option.get_name()
		%NamesList.add_child(name_label)

		# TODO: get from a config file.
		var current_setting_index: int = option.get_default_setting()
		_settings_indices.append(current_setting_index)

		var settings_h_box := HBoxContainer.new()
		for setting_index: int in option.get_settings().size():
			var setting_label := Label.new()
			setting_label.text = option.get_settings()[setting_index]
			setting_label.theme_type_variation = (
				&"BlueLabel" if setting_index == current_setting_index else &"GrayLabel"
			)
			settings_h_box.add_child(setting_label)
		%SettingsList.add_child(settings_h_box)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up", true):
		_current_index -= 1
	if event.is_action_pressed("down", true):
		_current_index += 1


func _process(_delta: float) -> void:
	_scroll_container.scroll_vertical = _top_index * 16


func _get_relative_index() -> int:
	return _current_index - _top_index
