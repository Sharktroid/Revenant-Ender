## A progress bar that displays an integer or floating point value, instead of just a percentage.
class_name NumericProgressBar
extends ReferenceRect

## The modes that the value is displayed in.
enum Modes { INTEGER, FLOAT, PERCENT }

## Whether the bar uses the original value.
@export var two_valued: bool = false
## The current mode.
@export var mode: Modes = Modes.FLOAT:
	set(new_value):
		mode = new_value
		for bar: ProgressBar in _progress_bars:
			bar.min_value = value
			if mode == Modes.INTEGER:
				bar.step = 1
			else:
				bar.step = 0.01
## The value of the bar.
var value: float:
	get:
		return value
	set(new_value):
		value = new_value
		_update()
## The value without any modifiers. Can be used to display debuffs.
var original_value: float:
	get:
		return original_value
	set(new_value):
		original_value = new_value
		two_valued = true
		_update()
## The minimum value that the bar can be.
var min_value: float:
	get:
		return _progress_bar_yellow.min_value
	set(value):
		for bar: ProgressBar in _progress_bars:
			bar.min_value = value
## The maximum value that the bar can be.
var max_value: float:
	get:
		return _progress_bar_yellow.max_value
	set(value):
		for bar: ProgressBar in _progress_bars:
			bar.max_value = value

@onready var _progress_bar_red := %ProgressBarRed as ProgressBar
@onready var _progress_bar_green := %ProgressBarGreen as ProgressBar
@onready var _progress_bar_yellow := %ProgressBarYellow as ProgressBar
@onready var _value_label := %ValueLabel as Label
@onready var _progress_bars: Array[ProgressBar] = [
	_progress_bar_red, _progress_bar_green, _progress_bar_yellow
]


## Creates a new instance.
static func instantiate(
	new_value: float, minimum: float, maximum: float, new_mode := Modes.INTEGER, og_value: float = new_value
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
		if new_value != og_value:
			scene.original_value = og_value
	coroutine.call()
	return scene


func _update() -> void:
	var greater_value: bool = value > original_value
	if greater_value:
		_progress_bar_green.visible = true
		_progress_bar_red.visible = false
		_progress_bar_green.value = value
		_progress_bar_yellow.value = original_value if two_valued else value
	else:
		_progress_bar_green.visible = false
		_progress_bar_red.visible = true
		_progress_bar_yellow.value = value
		_progress_bar_red.value = original_value

	_value_label.text = _get_value_text()
	if two_valued:
		_value_label.theme_type_variation = _get_theme_variation()


func _get_value_text() -> String:
	match mode:
		Modes.INTEGER:
			return Utilities.float_to_string(value, true)
		Modes.PERCENT:
			return (
				Utilities.float_to_string(snappedf(value / max_value * 100, 0.001)) + "%"
			)
		_:
			return Utilities.float_to_string(snappedf(value, 0.001))


func _get_theme_variation() -> StringName:
	match sign(value - original_value) as int:
		1:
			return &"GreenLabel"
		-1:
			return &"RedLabel"
		_:
			return &"BlueLabel"
