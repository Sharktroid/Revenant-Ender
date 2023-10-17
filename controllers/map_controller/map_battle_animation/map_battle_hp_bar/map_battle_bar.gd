@tool
extends Control

@export_color_no_alpha var top_color: Color
@export_color_no_alpha var bottom_color: Color

func _process(delta: float) -> void:
	var gradient: Gradient = %"BG Gradient".get_theme_stylebox("panel").texture.gradient
#	gradient.set_color(0, Color.DODGER_BLUE)
#	gradient.set_color(1, Color.STEEL_BLUE)
