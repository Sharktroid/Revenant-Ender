class_name NumericProgressBar
extends ReferenceRect

enum Modes { INTEGER, FLOAT, PERCENT }

@export var mode: Modes
var value: float:
	get:
		return _progress_bar_yellow.value
	set(new_value):
		_progress_bar_yellow.value = new_value
		match mode:
			Modes.FLOAT:
				_value_label.text = Utilities.float_to_string(new_value)
			Modes.INTEGER:
				if abs(new_value) == INF:
					_value_label.text = (
						Utilities.INF_CHAR if new_value == INF else "-%s" % Utilities.INF_CHAR
					)
				else:
					_value_label.text = Utilities.float_to_string(roundi(new_value))
			Modes.PERCENT:
				_value_label.text = (
					Utilities.float_to_string(
						Utilities.round_to_places(new_value / max_value * 100, 3)
					)
					+ "%"
				)
var original_value: float:
	get:
		return _progress_bar_red.value
	set(new_value):
		_progress_bar_red.value = new_value
		_value_label.theme_type_variation = (
			&"RedLabel" if value < original_value else &"BlueLabel"
		)
var min_value: float:
	get:
		return _progress_bar_yellow.min_value
	set(value):
		_progress_bar_red.min_value = value
		_progress_bar_yellow.min_value = value
var max_value: float:
	get:
		return _progress_bar_yellow.max_value
	set(value):
		_progress_bar_red.max_value = value
		_progress_bar_yellow.max_value = value

@onready var _progress_bar_red := %ProgressBarRed as ProgressBar
@onready var _progress_bar_yellow := %ProgressBarYellow as ProgressBar
@onready var _value_label := %ValueLabel as Label
