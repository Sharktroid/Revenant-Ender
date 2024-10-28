## A menu that displays a list of options
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
				_top_index = _get_top_index_max()
			elif _get_relative_index() == _displayed_item_count() - 1:
				_top_index += 1
			elif _get_relative_index() == 0:
				_top_index -= 1
			_update_hand_y()
			_hovered_setting_index = _current_setting_index
# The index of the top-displayed item.
var _top_index: int = 0:
	set(value):
		_top_index = clampi(value, 0, _get_top_index_max())
		_scroll_tween = create_tween()
		_scroll_tween.set_speed_scale(60)
		_scroll_tween.tween_property(_scroll_container, "scroll_vertical", _top_index * 16, 4)

# A Tween that controls cursor movement between settings.
var _horizontal_tween: Tween = create_tween()
# A Tween that controls cursor movement between options.
var _vertical_tween: Tween = create_tween()
# A Tween that controls the scrolling of the menu.
var _scroll_tween: Tween = create_tween()

# The scroll container that scrolls to fit the content
@onready var _scroll_container := %ScrollContainer as ScrollContainer
# The hand sprite for the row
@onready var _row_hand_sprite := $RowHand as Sprite2D
# The hand sprite for the column
@onready var _column_hand_sprite := $ColumnHand as Sprite2D
# The starting y for the had sprites
@onready var _hand_starting_y: int = roundi(_row_hand_sprite.position.y)


func _ready() -> void:
	GameController.add_to_input_stack(self)
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
	_horizontal_tween.stop()
	_vertical_tween.stop()
	_scroll_tween.stop()
	_column_hand_sprite.position.x = _get_column_hand_x()


func _receive_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not _scroll_tween.is_running():
		#region Mouse handling
		_toggle_hands(false)
		_current_index = (clampi(
			floori(_scroll_container.get_local_mouse_position().y / 16) + _top_index,
			0,
			_options.size() - 1
		))
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
		#endregion
	elif event is InputEventKey:
		if _column_hand_sprite.visible:
			if not _vertical_tween.is_running():
				if event.is_action_pressed("up", true) and not Input.is_action_pressed("down"):
					_current_index -= 1
					AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_V)
				elif event.is_action_pressed("down", true):
					_current_index += 1
					AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_V)

			if not _horizontal_tween.is_running():
				if event.is_action_pressed("left", true) and not Input.is_action_pressed("right"):
					_current_setting_index -= 1
					AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_H)
				elif event.is_action_pressed("right", true):
					_current_setting_index += 1
					AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_H)
		else:
			_hovered_setting_index = _current_setting_index
			_toggle_hands(true)
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_H)

	if event.is_action_pressed("ui_accept") and _current_setting_index != _hovered_setting_index:
		_current_setting_index = _hovered_setting_index
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
	elif event.is_action_pressed("ui_cancel"):
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		queue_free()


func _physics_process(_delta: float) -> void:
	if not _scroll_tween.is_running() and not _column_hand_sprite.visible:
		if _scroll_container.get_local_mouse_position().y <= 16:
			_top_index -= 1
		elif _scroll_container.get_local_mouse_position().y >= _scroll_container.size.y - 16:
			_top_index += 1


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
	if _column_hand_sprite.visible:
		_horizontal_tween = _column_hand_sprite.create_tween()
		_horizontal_tween.set_speed_scale(60)
		_horizontal_tween.set_trans(Tween.TRANS_QUAD)
		_horizontal_tween.tween_property(_column_hand_sprite, "position:x", _get_column_hand_x(), 5)
	else:
		_column_hand_sprite.position.x = _get_column_hand_x()


# Gets the column hand's x
func _get_column_hand_x() -> float:
	return _get_hovered_setting_label().global_position.x


# Updates the hand's y
func _update_hand_y() -> void:
	var new_hand_y: float = _hand_starting_y + _get_relative_index() * 16
	if _column_hand_sprite.visible:
		_vertical_tween = _column_hand_sprite.create_tween()
		_vertical_tween.set_speed_scale(60)
		_vertical_tween.set_trans(Tween.TRANS_QUAD)
		_vertical_tween.set_parallel()
		#var speed: float = 5 * minf(1, absf(new_hand_y - _column_hand_sprite.position.y) / 16)
		_vertical_tween.tween_property(_column_hand_sprite, "position:y", new_hand_y, 5)
		_vertical_tween.tween_property(_row_hand_sprite, "position:y", new_hand_y, 5)
	else:
		_column_hand_sprite.position.y = new_hand_y
		_row_hand_sprite.position.y = new_hand_y


# Gets the selected color for the label.
func _get_label_color(label: Label) -> StringName:
	match label.text:
		"Off":
			return &"RedLabel"
		"On", "Max":
			return &"GreenLabel"
		_:
			return &"BlueLabel"


# The number of displayed items.
func _displayed_item_count() -> int:
	return ceili(_scroll_container.size.y / 16)


# Hides hand cursors.
func _toggle_hands(visiblity: bool) -> void:
	_row_hand_sprite.visible = visiblity
	_column_hand_sprite.visible = visiblity


# Gets the maximum value for the top index
func _get_top_index_max() -> int:
	return maxi(_options.size() - _displayed_item_count(), 0)
