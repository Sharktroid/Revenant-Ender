@tool
extends Control

@export_range(0, 1) var hue_min: float = 0
@export_range(0, 1) var hue_max: float = 1
@export var duration: float = 2


func _enter_tree() -> void:
	_update_hue()


func _process(_delta: float) -> void:
	_update_hue()


func _update_hue() -> void:
	for child: Node in $Features.get_children():
		if child is Polygon2D:
			var polygon := child as Polygon2D
			var child_pos: Vector2i = polygon.position
			var child_offset: int = child_pos.x * 2 + child_pos.y
			var modifed_offset := float(rand_from_seed(child_offset)[0]) / (2 ** 32)
			var offset_weight: float = fmod((modifed_offset + _get_time_in_seconds()) / duration, 1)
			polygon.color.h = lerpf(hue_min, hue_max, offset_weight)


func _get_time_in_seconds() -> float:
	return float(Time.get_ticks_msec()) / 1000
