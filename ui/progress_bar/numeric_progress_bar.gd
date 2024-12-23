## A progress bar that displays an integer or floating point value, instead of just a percentage.
class_name NumericProgressBar
extends ReferenceRect

## The modes that the value is displayed in.
enum Modes { INTEGER, FLOAT, PERCENT }

## The current mode.
@export var mode: Modes:
	set(new_value):
		mode = new_value
		if mode == Modes.INTEGER:
			_progress_bar_red.step = 1
			_progress_bar_yellow.step = 1
		else:
			_progress_bar_red.step = 0.01
			_progress_bar_yellow.step = 0.01
## The value of the bar.
var value: float:
	get:
		return _progress_bar_yellow.value
	set(new_value):
		_progress_bar_yellow.value = new_value
		match mode:
			Modes.FLOAT:
				_value_label.text = Utilities.float_to_string(snappedf(new_value, 0.001))
			Modes.INTEGER:
				if abs(new_value) == INF:
					_value_label.text = (
						Utilities.INF_CHAR if new_value == INF else "-%s" % Utilities.INF_CHAR
					)
				else:
					_value_label.text = Utilities.float_to_string(roundi(new_value))
			Modes.PERCENT:
				_value_label.text = (
					Utilities.float_to_string(snappedf(new_value / max_value * 100, 0.001)) + "%"
				)
## The value without any modifiers. Can be used to display debuffs.
var original_value: float:
	get:
		return _progress_bar_red.value
	set(new_value):
		_progress_bar_red.value = new_value
		_value_label.theme_type_variation = (
			&"RedLabel" if value < original_value else &"BlueLabel"
		)
## The minimum value that the bar can be.
var min_value: float:
	get:
		return _progress_bar_yellow.min_value
	set(value):
		_progress_bar_red.min_value = value
		_progress_bar_yellow.min_value = value
## The maximum value that the bar can be.
var max_value: float:
	get:
		return _progress_bar_yellow.max_value
	set(value):
		_progress_bar_red.max_value = value
		_progress_bar_yellow.max_value = value

@onready var _progress_bar_red := %ProgressBarRed as ProgressBar
@onready var _progress_bar_yellow := %ProgressBarYellow as ProgressBar
@onready var _value_label := %ValueLabel as Label


## Creates a new instance.
static func instantiate(
	new_value: float, minimum: float, maximum: float, new_mode := Modes.INTEGER, og_value: int = 0
) -> NumericProgressBar:
	const PACKED_SCENE: PackedScene = preload("res://ui/progress_bar/numeric_progress_bar.tscn")
	var scene := PACKED_SCENE.instantiate() as NumericProgressBar
	#gdlint: ignore = private-method-call
	var coroutine: Callable = func() -> void:
		if not scene.is_node_ready():
			await scene.ready
		scene.max_value = maximum
		scene.min_value = minimum
		scene.mode = new_mode
		scene.value = new_value
		scene.original_value = og_value
	coroutine.call()
	return scene
