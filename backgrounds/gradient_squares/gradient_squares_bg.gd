@tool
extends Control

@export_range(0, 1) var hue_min: float = 0
@export_range(0, 1) var hue_max: float = 1
@export var duration: float = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_hue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_update_hue()


func _update_hue() -> void:
	for child in $Features.get_children():
		if child is Polygon2D:
			var child_pos: Vector2i = child.position
			var child_offset: int = child_pos.x*2 + child_pos.y
			var modifed_offset: float = float(rand_from_seed(child_offset)[0])/(2**32)
			var offset_weight: float = fmod((modifed_offset + _get_time_in_seconds()) / duration, 1)
			var new_hue: float = lerp(hue_min, hue_max, offset_weight)
	#		print_debug(new_hue)
			child.color.h = new_hue


func _get_time_in_seconds() -> float:
	return float(Time.get_ticks_msec()) / 1000
