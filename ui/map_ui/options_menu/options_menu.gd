extends Control

# Object that handles options.
const _OPTION := preload("res://ui/map_ui/options_menu/option.gd")
# List of options.
var _options: Array[_OPTION] = [
	_OPTION.new("Animations", ["Map", "Off"]),
	_OPTION.new("Game Speed", ["Normal", "Max"]),
	_OPTION.new("Text Speed", ["Slow", "Medium", "Fast", "Max"], 1),
	_OPTION.new("Terrain", ["On", "Off"]),
	_OPTION.new("Unit Panel", ["Panel", "Bubble", "Off"]),
	_OPTION.new("Combat Panel", ["Strategic", "Detailed", "Off"]),
]

# The indices of the selected options' settings.
var _settings_indices: Array[int]
# The index of the current option's setting.
var _current_setting_index: int:
	get:
		return _settings_indices[_current_index]
	set(value):
		_current_setting_index = posmod(value, _options[_current_index].get_settings().size())
		_get_current_setting_label().theme_type_variation = &"GrayLabel"
		_settings_indices[_current_index] = posmod(
			value, _options[_current_index].get_settings().size()
		)
		_get_current_setting_label().theme_type_variation = _get_label_color(
			_get_current_setting_label()
		)
		_hovered_setting_index = _current_setting_index
# The index of the option setting that the mouse is hovering over.
var _hovered_setting_index: int:
	set(value):
		if value != _hovered_setting_index:
			_hovered_setting_index = posmod(value, _options[_current_index].get_settings().size())
			_update_column_hand_x()
# The index of the current option.
var _current_index: int = 0:
	set(value):
		if value != _current_index:
			_current_index = posmod(value, _options.size())
			if _current_index == 0:
				_top_index = 0
			elif _current_index == _options.size() - 1:
				_top_index = _options.size() - _displayed_item_count
			elif _get_relative_index() == _displayed_item_count:
				_top_index += 1
			elif _get_relative_index() == 0:
				_top_index -= 1
			_update_hand_y()
			_hovered_setting_index = _current_setting_index
# The index of the top-displayed item.
var _top_index: int = 0
# The number of displayed items.
var _displayed_item_count: int = _options.size()
# A Tween that controls cursor movement between settings.
var _horizontal_tween: Tween = create_tween()
# A Tween that controls cursor movement between options.
var _vertical_tween: Tween = create_tween()

# The scroll container that scrolls to fit the content
@onready var _scroll_container := %ScrollContainer as ScrollContainer
# The hand sprite for the row
@onready var _row_hand_sprite := $RowHand as Sprite2D
# The hand sprite for the column
@onready var _column_hand_sprite := $ColumnHand as Sprite2D
# The starting y for the had sprites
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
				_get_label_color(setting_label)
				if setting_index == current_setting_index
				else &"GrayLabel"
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
	if event.is_action_pressed("ui_accept"):
		_current_setting_index = _hovered_setting_index
	if event is InputEventMouseMotion:
		#var raw_index: float =
		_current_index = clampi(
			floori(_scroll_container.get_local_mouse_position().y / 16), 0, _options.size() - 1
		)
		var setting_box := %SettingsList.get_child(_current_index) as HBoxContainer
		var last_label := setting_box.get_children().back() as Label
		if setting_box.get_local_mouse_position().x < 0:
			_hovered_setting_index = 0
		elif (
			setting_box.get_global_mouse_position().x
			>= last_label.global_position.x + last_label.size.x
		):
			_hovered_setting_index = setting_box.get_child_count() - 1
		else:
			for index: int in setting_box.get_child_count():
				var setting := setting_box.get_child(index) as Label
				var mouse_x: float = setting.get_local_mouse_position().x
				if mouse_x >= 0 and mouse_x < setting.size.x:
					_hovered_setting_index = index


func _process(_delta: float) -> void:
	_scroll_container.scroll_vertical = _top_index * 16


# Gets the relative index compared to the top index
func _get_relative_index() -> int:
	return _current_index - _top_index


# The setting label for the current index
func _get_current_setting_label() -> Label:
	return (%SettingsList).get_child(_current_index).get_child(_current_setting_index) as Label


# The setting label for the current index
func _get_hovered_setting_label() -> Label:
	return (%SettingsList).get_child(_current_index).get_child(_hovered_setting_index) as Label


# Updates the x of the column hand
func _update_column_hand_x() -> void:
	_horizontal_tween.stop()
	_horizontal_tween = _column_hand_sprite.create_tween()
	_horizontal_tween.set_speed_scale(60)
	_horizontal_tween.set_trans(Tween.TRANS_QUAD)
	_horizontal_tween.tween_property(_column_hand_sprite, "position:x", _get_column_hand_x(), 5)


# Gets the column hand's x
func _get_column_hand_x() -> float:
	return _get_hovered_setting_label().global_position.x


# Updates the hand's y
func _update_hand_y() -> void:
	_vertical_tween.stop()
	var new_hand_y: float = _hand_starting_y + _get_relative_index() * 16
	_vertical_tween = _column_hand_sprite.create_tween()
	_vertical_tween.set_speed_scale(60)
	_vertical_tween.set_trans(Tween.TRANS_QUAD)
	_vertical_tween.set_parallel()
	var speed: float = 5 * minf(1, absf(new_hand_y - _column_hand_sprite.position.y) / 16)
	_vertical_tween.tween_property(_column_hand_sprite, "position:y", new_hand_y, speed)
	_vertical_tween.tween_property(_row_hand_sprite, "position:y", new_hand_y, speed)


# Gets the selected color for the label.
func _get_label_color(label: Label) -> StringName:
	match label.text:
		"Off":
			return &"RedLabel"
		"On", "Max":
			return &"GreenLabel"
		_:
			return &"BlueLabel"
