## A menu that displays a list of options
extends Control

# The indices of the selected options' settings.
var _settings_indices: Dictionary
# The index of the current option's setting.
var _current_setting_index: int:
	get:
		return _settings_indices[_get_current_option()]
	set(value):
		_current_setting_index = posmod(value, _get_settings_count())
		_get_current_setting_label().theme_type_variation = &"GrayLabel"
		_settings_indices[_get_current_option()] = posmod(value, _get_settings_count())
		_get_current_setting_label().theme_type_variation = _get_label_color(
			_get_current_setting_label()
		)
		if _get_current_option() is BooleanOption:
			(_get_current_option() as BooleanOption).value = (
				_get_current_setting_label().text == "On"
			)
		else:
			(_get_current_option() as StringNameOption).value = (
				_get_current_setting_label().text.to_snake_case()
			)
		_hovered_setting_index = _current_setting_index
# The index of the option setting that the mouse is hovering over.
var _hovered_setting_index: int:
	set(value):
		if value != _hovered_setting_index:
			_hovered_setting_index = posmod(value, _get_settings_count())
			_update_column_hand_x()
			_update_description()
# The index of the current option.
var _current_index: int = 0:
	set(value):
		if value != _current_index:
			_current_index = posmod(value, Options.get_options().size())
			if _current_index == 0:
				_top_index = 0
			elif _current_index == Options.get_options().size() - 1:
				_top_index = _get_top_index_max()
			elif _get_relative_index() == _displayed_item_count() - 1:
				_top_index += 1
			elif _get_relative_index() == 0:
				_top_index -= 1
			_update_hand_y()
			if _get_current_option() is not FloatOption:
				_hovered_setting_index = _current_setting_index
			_update_description()
# The index of the top-displayed item.
var _top_index: int = 0:
	set(value):
		_top_index = clampi(value, 0, _get_top_index_max())
		_scroll_tween = create_tween()
		_scroll_tween.set_speed_scale(60)
		_scroll_tween.tween_property(_scroll_container, ^"scroll_vertical", _top_index * 16, 4)

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
	MapController.map.process_mode = Node.PROCESS_MODE_DISABLED
	for option: ConfigOption in Options.get_options():
		var icon_rect := TextureRect.new()
		icon_rect.texture = load("res://ui/map_ui/options_menu/icons/%s.png" % option.get_name())
		var icon_center := CenterContainer.new()
		icon_center.custom_minimum_size = Vector2i(16, 16)
		icon_center.add_child(icon_rect)
		%IconsList.add_child(icon_center)

		var name_label := Label.new()
		name_label.text = option.get_name().capitalize()
		%NamesList.add_child(name_label)

		if option is FloatOption:
			var float_option := option as FloatOption
			var progress_bar := NumericProgressBar.instantiate(
				float_option.value,
				float_option.get_min(),
				float_option.get_max(),
				NumericProgressBar.Modes.FLOAT
			)
			progress_bar.custom_minimum_size.x = 200
			%SettingsList.add_child(progress_bar)
		else:
			var settings_h_box := HBoxContainer.new()
			if option is BooleanOption:
				_settings_indices[option] = 0 if (option as BooleanOption).value else 1
				settings_h_box.add_child(_create_label("On"))
				settings_h_box.add_child(_create_label("Off"))
			elif option is StringNameOption:
				var string_name_option := option as StringNameOption
				_settings_indices[option] = string_name_option.get_settings().find(
					string_name_option.value
				)
				for setting_index: int in string_name_option.get_settings().size():
					settings_h_box.add_child(
						_create_label(string_name_option.get_settings()[setting_index].capitalize())
					)
			var label := settings_h_box.get_child(_settings_indices[option] as int) as Label
			label.theme_type_variation = _get_label_color(label)
			%SettingsList.add_child(settings_h_box)
	_horizontal_tween.stop()
	_vertical_tween.stop()
	_scroll_tween.stop()
	_update_description()
	await get_tree().process_frame
	if _get_current_option() is not FloatOption:
		_hovered_setting_index = _current_setting_index
	_column_hand_sprite.position.x = _get_column_hand_x()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not _scroll_tween.is_running():
		#region Mouse handling
		_current_index = clampi(
			floori(_scroll_container.get_local_mouse_position().y / 16) + _top_index,
			0,
			Options.get_options().size() - 1
		)
		if _get_current_option() is not FloatOption:
			var setting_box := %SettingsList.get_child(_current_index) as HBoxContainer
			var last_label := setting_box.get_children().back() as Control
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
		if not _vertical_tween.is_running():
			if event.is_action_pressed("up", true) and not Input.is_action_pressed("down"):
				_current_index -= 1
				AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_V)
			elif event.is_action_pressed("down", true):
				_current_index += 1
				AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_V)

		if not _horizontal_tween.is_running():
			if event.is_action_pressed("left", true) and not Input.is_action_pressed("right"):
				if _get_current_option() is FloatOption:
					if snappedf(_get_progress_bar().value, 0.1) != _get_progress_bar().value:
						_set_progress_bar_value(
							_get_progress_bar().value - fmod(_get_progress_bar().value, 0.1)
						)
					else:
						_set_progress_bar_value(_get_progress_bar().value - 0.1)
				else:
					_current_setting_index -= 1
				AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_H)
			elif event.is_action_pressed("right", true):
				if _get_current_option() is FloatOption:
					var new_value: float = _get_progress_bar().value + 0.1
					if snappedf(_get_progress_bar().value, 0.1) != _get_progress_bar().value:
						new_value -= fmod(_get_progress_bar().value, 0.1)
					_set_progress_bar_value(new_value)
				else:
					_current_setting_index += 1
				AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_H)

	if event.is_action_pressed("back"):
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		queue_free()


func _physics_process(_delta: float) -> void:
	if not _scroll_tween.is_running() and not _column_hand_sprite.visible:
		if _scroll_container.get_local_mouse_position().y <= 16:
			_top_index -= 1
		elif _scroll_container.get_local_mouse_position().y >= _scroll_container.size.y - 16:
			_top_index += 1
	if Input.is_action_pressed("select"):
		if _get_current_option() is FloatOption:
			_set_progress_bar_value(
				_get_progress_bar().get_local_mouse_position().x / _get_progress_bar().size.x
			)
		elif _current_setting_index != _hovered_setting_index:
			_current_setting_index = _hovered_setting_index
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)


func _exit_tree() -> void:
	MapController.map.process_mode = Node.PROCESS_MODE_INHERIT
	CursorController.enable()


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
	var new_x: float
	if _get_current_option() is FloatOption:
		new_x = 0
	else:
		new_x = _get_column_hand_x()
	_horizontal_tween = _column_hand_sprite.create_tween()
	_horizontal_tween.set_speed_scale(60)
	_horizontal_tween.set_trans(Tween.TRANS_QUAD)
	_horizontal_tween.tween_property(_column_hand_sprite, ^"position:x", new_x, 5)


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
		_vertical_tween.tween_property(_column_hand_sprite, ^"position:y", new_hand_y, 5)
		_vertical_tween.tween_property(_row_hand_sprite, ^"position:y", new_hand_y, 5)
	else:
		_column_hand_sprite.position.y = new_hand_y
		_row_hand_sprite.position.y = new_hand_y


# Gets the selected color for the label.
func _get_label_color(label: Label) -> StringName:
	match label.text:
		"Off":
			return &"RedLabel"
		"On", "Max", "All":
			return &"GreenLabel"
		_:
			return &"BlueLabel"


# The number of displayed items.
func _displayed_item_count() -> int:
	return ceili(_scroll_container.size.y / 16)


# Gets the maximum value for the top index
func _get_top_index_max() -> int:
	return maxi(Options.get_options().size() - _displayed_item_count(), 0)


func _get_current_option() -> ConfigOption:
	return Options.get_options()[_current_index]


func _get_settings_count() -> int:
	if _get_current_option() is StringNameOption:
		return (_get_current_option() as StringNameOption).get_settings().size()
	else:
		return 11 if _get_current_option() is FloatOption else 2


func _create_label(setting: StringName) -> Label:
	var setting_label := Label.new()
	setting_label.text = setting
	setting_label.theme_type_variation = (&"GrayLabel")
	return setting_label


func _update_description() -> void:
	var get_current_option_value: Callable = func() -> String:
		if _get_current_option() is FloatOption:
			return var_to_str(_get_progress_bar().value)
		else:
			return _get_hovered_setting_label().text.to_snake_case()
	(%DescriptionLabel as Label).text = _get_current_option().get_description(
		get_current_option_value.call() as StringName
	)


func _get_progress_bar() -> NumericProgressBar:
	return %SettingsList.get_child(_current_index) as NumericProgressBar


func _set_progress_bar_value(value: float) -> void:
	var clamped_value: float = clampf(
		value, _get_progress_bar().min_value, _get_progress_bar().max_value
	)
	_get_progress_bar().value = clamped_value
	(_get_current_option() as FloatOption).value = clamped_value
