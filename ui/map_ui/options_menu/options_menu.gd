## A menu that displays a list of options
extends Control

# The indices of the selected options' settings.
var _settings_indices: Dictionary[ConfigOption, int]
# The index of the current option's setting.
var _current_setting_index: int:
	get = _get_current_setting_index,
	set = _set_current_setting_index
# The index of the option setting that the mouse is hovering over.
var _hovered_setting_index: int:
	set(value):
		if value != _hovered_setting_index:
			_hovered_setting_index = posmod(value, _get_settings_count())
			_update_column_hand_x()
			_update_description()
# The index of the current option.
var _current_index: int = 0:
	set = _set_current_value
# The index of the top-displayed item.
var _top_index: int = 0:
	set(value):
		_top_index = clampi(value, 0, _get_top_index_max())
		_scroll_tween = create_tween()
		_scroll_tween.set_speed_scale(60)
		_scroll_tween.tween_property(_scroll_container, ^"scroll_vertical", _top_index * 16, 4)

# A Tween that controls cursor movement between settings.
var _horizontal_tween: Tween
# A Tween that controls cursor movement between options.
var _vertical_tween: Tween
# A Tween that controls the scrolling of the menu.
var _scroll_tween: Tween

# The scroll container that scrolls to fit the content
@onready var _scroll_container := %ScrollContainer as ScrollContainer
# The hand sprite for the row
@onready var _row_hand_sprite := $RowHand as Sprite2D
# The hand sprite for the column
@onready var _column_hand_sprite := $ColumnHand as Sprite2D
# The starting y for the had sprites
@onready var _hand_starting_y: int = roundi(_row_hand_sprite.position.y)
@onready var _tab_bar := %TabBar as TabBar


func _ready() -> void:
	MapController.map.process_mode = Node.PROCESS_MODE_DISABLED
	_horizontal_tween = create_tween()
	_horizontal_tween.stop()
	_vertical_tween = create_tween()
	_vertical_tween.stop()
	_scroll_tween = create_tween()
	_scroll_tween.stop()

	_create_options()
	_update_description()
	await get_tree().process_frame
	if _get_current_option() is not FloatOption:
		_hovered_setting_index = _current_setting_index
	_column_hand_sprite.position.x = _get_column_hand_x()

	_tab_bar.clear_tabs()
	for category: StringName in Options.get_options().keys():
		_tab_bar.add_tab(category.capitalize())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not _scroll_tween.is_running():
		_update_mouse_position()
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
				_move(-1)
			elif event.is_action_pressed("right", true):
				_move(1)
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


func _get_current_options() -> Array[ConfigOption]:
	var output: Array[ConfigOption] = []
	var options: Array = Options.get_options().get(_get_current_tab(), [])
	output.assign(options)
	return output


func _add_icon(option: ConfigOption) -> void:
	var icon_rect := TextureRect.new()
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var texture_path: String = "res://ui/map_ui/options_menu/icons/%s.png" % option.get_name()
	if ResourceLoader.exists(texture_path):
		icon_rect.texture = load(texture_path)
	else:
		icon_rect.texture = PlaceholderTexture2D.new()
		icon_rect.size = Vector2(16, 16)
	var icon_center := CenterContainer.new()
	icon_center.custom_minimum_size = Vector2i(16, 16)
	icon_center.add_child(icon_rect)
	%IconsList.add_child(icon_center)


func _create_options() -> void:
	for option: ConfigOption in _get_current_options():
		_add_icon(option)
		var name_label := Label.new()
		name_label.text = option.get_name().capitalize()
		%NamesList.add_child(name_label)

		if option is FloatOption:
			_create_float_option(option as FloatOption)
		else:
			var settings_h_box := HBoxContainer.new()
			if option is BooleanOption:
				_create_bool_option(settings_h_box, option as BooleanOption)
			elif option is StringNameOption:
				_create_string_option(settings_h_box, option as StringNameOption)
			var label := settings_h_box.get_child(_settings_indices[option]) as Label
			label.theme_type_variation = _get_label_color(label)
			%SettingsList.add_child(settings_h_box)


func _create_float_option(option: FloatOption) -> void:
	var progress_bar := NumericProgressBar.instantiate(
		option.value, option.get_min(), option.get_max(), NumericProgressBar.Modes.FLOAT
	)
	progress_bar.custom_minimum_size.x = 200
	%SettingsList.add_child(progress_bar)


func _create_bool_option(settings_h_box: HBoxContainer, option: BooleanOption) -> void:
	_settings_indices[option] = 0 if option.value else 1
	settings_h_box.add_child(_create_label("On"))
	settings_h_box.add_child(_create_label("Off"))


func _create_string_option(settings_h_box: HBoxContainer, option: StringNameOption) -> void:
	_settings_indices[option] = option.get_settings().find(option.value)
	for setting_index: int in option.get_settings().size():
		settings_h_box.add_child(_create_label(option.get_settings()[setting_index].capitalize()))


# Gets the relative index compared to the top index
func _get_relative_index() -> int:
	return _current_index - _top_index


func _set_current_setting_index(value: int) -> void:
	_current_setting_index = posmod(value, _get_settings_count())
	_get_current_setting_label().theme_type_variation = &"GrayLabel"
	_settings_indices[_get_current_option()] = posmod(value, _get_settings_count())
	_get_current_setting_label().theme_type_variation = _get_label_color(
		_get_current_setting_label()
	)
	if _get_current_option() is BooleanOption:
		(_get_current_option() as BooleanOption).value = (_get_current_setting_label().text == "On")
	else:
		(_get_current_option() as StringNameOption).value = (
			_get_current_setting_label().text.to_snake_case()
		)
	_hovered_setting_index = _current_setting_index


# The setting label for the current index
func _get_current_setting_label() -> Label:
	return (%SettingsList).get_child(_current_index).get_child(_current_setting_index) as Label


func _get_current_setting_index() -> int:
	return _settings_indices[_get_current_option()]


# The setting label for the current index
func _get_hovered_setting_label() -> Label:
	return (%SettingsList).get_child(_current_index).get_child(_hovered_setting_index) as Label


func _set_current_value(value: int) -> void:
	if value != _current_index:
		_current_index = posmod(value, _get_current_options().size())
		if _current_index == 0:
			_top_index = 0
		elif _current_index == _get_current_options().size() - 1:
			_top_index = _get_top_index_max()
		elif _get_relative_index() == _displayed_item_count() - 1:
			_top_index += 1
		elif _get_relative_index() == 0:
			_top_index -= 1
		_update_hand_y()
		if _get_current_option() is not FloatOption:
			_hovered_setting_index = _current_setting_index
		_update_description()


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
	return maxi(_get_current_options().size() - _displayed_item_count(), 0)


func _get_current_option() -> ConfigOption:
	return _get_current_options()[_current_index]


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


func _update_mouse_position() -> void:
	_current_index = clampi(
		floori(_scroll_container.get_local_mouse_position().y / 16) + _top_index,
		0,
		_get_current_options().size() - 1
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


func _move(dir: int) -> void:
	if _get_current_option() is FloatOption:
		_set_progress_bar_value(_get_clamped_float_value(0.1 * dir))
	else:
		_current_setting_index += 1 * dir
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_TICK_H)


func _get_clamped_float_value(added_value: float) -> float:
	var new_value: float = _get_progress_bar().value + added_value
	if snappedf(_get_progress_bar().value, 0.1) != _get_progress_bar().value:
		if added_value < 0:
			return _get_progress_bar().value - fmod(_get_progress_bar().value, 0.1)
		else:
			new_value -= fmod(_get_progress_bar().value, 0.1)
	return new_value


func _get_current_tab() -> StringName:
	return (_tab_bar.get_tab_title(_tab_bar.current_tab).to_lower()) as StringName


func _on_tab_bar_tab_clicked(_tab: int) -> void:
	process_mode = Node.PROCESS_MODE_DISABLED  # Halts updates until the menu has been updated
	for child: Node in (
		%SettingsList.get_children() + %IconsList.get_children() + %NamesList.get_children()
	):
		child.queue_free()
		await child.tree_exited
	_settings_indices = {}
	_create_options()
	_update_description()
	process_mode = Node.PROCESS_MODE_INHERIT
