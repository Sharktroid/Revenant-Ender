extends Control

const _OPTION := preload("res://ui/map_ui/options_menu/option.gd")
var _options: Array[_OPTION] = [
	_OPTION.new("Animations", ["Map", "Off"]),
	_OPTION.new("Game Speed", ["Normal", "Max"]),
	_OPTION.new("Text Speed", ["Slow", "Medium", "Fast", "Max"], 1),
	_OPTION.new("Terrain", ["On", "Off"]),
	_OPTION.new("Unit Panel", ["Panel", "Bubble", "Off"]),
	_OPTION.new("Combat Panel", ["Strategic", "Detailed", "Off"]),
]

var _settings_indices: Array[int]
var _current_setting_index: int:
	get():
		return _settings_indices[_current_index]
	set(value):
		_get_current_setting_label().theme_type_variation = &"GrayLabel"
		_settings_indices[_current_index] = value % _options[_current_index].get_settings().size()
		_get_current_setting_label().theme_type_variation = &"BlueLabel"
		_update_column_hand_x()
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
		_update_column_hand_x()
		_update_hand_y()
var _top_index: int = 0
var _displayed_item_count: int = _options.size()
var _horizontal_tween: Tween = create_tween()
var _vertical_tween: Tween = create_tween()

@onready var _scroll_container := %ScrollContainer as ScrollContainer
@onready var _option_count: int = _options.size()
@onready var _row_hand_sprite := $RowHand as Sprite2D
@onready var _column_hand_sprite := $ColumnHand as Sprite2D
@onready var _hand_starting_y: int = roundi(_row_hand_sprite.position.y)


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
				_get_label_color(setting_label) if setting_index == current_setting_index else &"GrayLabel"
			)
			settings_h_box.add_child(setting_label)
		%SettingsList.add_child(settings_h_box)
	_horizontal_tween.tween_interval(0.001)
	_vertical_tween.tween_interval(0.001)
	await _horizontal_tween.finished
	_column_hand_sprite.position.x = _get_column_hand_x()


func _input(event: InputEvent) -> void:
	if not _vertical_tween.is_running():
		if event.is_action_pressed("up", true):
			_current_index -= 1
		elif event.is_action_pressed("down", true):
			_current_index += 1
	if not _horizontal_tween.is_running():
		if event.is_action_pressed("left", true):
			_current_setting_index -= 1
		elif event.is_action_pressed("right", true):
			_current_setting_index += 1


func _process(_delta: float) -> void:
	_scroll_container.scroll_vertical = _top_index * 16


func _get_relative_index() -> int:
	return _current_index - _top_index


func _get_current_setting_label() -> Label:
	return (%SettingsList).get_child(_current_index).get_child(_current_setting_index) as Label


func _update_column_hand_x() -> void:
	if not _horizontal_tween.is_running():
		_horizontal_tween = _column_hand_sprite.create_tween()
		_horizontal_tween.set_speed_scale(60)
		_horizontal_tween.set_trans(Tween.TRANS_QUAD)
		_horizontal_tween.tween_property(_column_hand_sprite, "position:x", _get_column_hand_x(), 5)


func _get_column_hand_x() -> float:
	return _get_current_setting_label().global_position.x


func _update_hand_y() -> void:
	if not _vertical_tween.is_running():
		var new_hand_y: float = (
			_hand_starting_y + _get_relative_index() * 16
		)
		_vertical_tween = _column_hand_sprite.create_tween()
		_vertical_tween.set_speed_scale(60)
		_vertical_tween.set_trans(Tween.TRANS_QUAD)
		_vertical_tween.set_parallel()
		_vertical_tween.tween_property(_column_hand_sprite, "position:y", new_hand_y, 5)
		_vertical_tween.tween_property(_row_hand_sprite, "position:y", new_hand_y, 5)
