@tool
extends Control

## Highest value that can be ever displayed.
const ABSOLUTE_MAX_VALUE: float = 30

var margins: Vector2i

@export var current_value: float
@export var max_value: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var margin_container: MarginContainer = %"Fill Margins"
	margin_container = (margin_container as MarginContainer)
	var left_margin: int = margin_container.get_theme_constant("margin_left")
	var right_margin: int = margin_container.get_theme_constant("margin_right")
	margins.x = left_margin + right_margin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	%"Value Label".text = str((current_value as int))
	$"Resize Handler".size.x = size.x * (float(max_value)/ABSOLUTE_MAX_VALUE)
	current_value = min(current_value, max_value)
	var percentage: float = float(current_value)/max_value
	%Fill.size.x = ($"Resize Handler".size.x - margins.x) * percentage
