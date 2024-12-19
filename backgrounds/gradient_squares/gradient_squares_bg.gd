## Scene that displays many squares that each cycle through colors based on a gradient.
@tool
extends ReferenceRect

## Minimum hue for gradient
@export_range(0, 1) var hue_min: float = 0
## Maximum hue for gradient
@export_range(0, 1) var hue_max: float = 1
## The length in time, in seconds, it takes to get from min to max hue
@export var duration: float = 2

var _hue_offsets: Dictionary


func _enter_tree() -> void:
	for polygon: Polygon2D in $Features.get_children():
		_hue_offsets[polygon] = inverse_lerp(
			0, 2 ** 64, rand_from_seed(roundi(polygon.position.x * 2 + polygon.position.y))[0]
		)

	_update_hue()


func _process(_delta: float) -> void:
	_update_hue()


func _update_hue() -> void:
	for polygon: Polygon2D in $Features.get_children():
		polygon.color.h = lerpf(
			hue_min,
			hue_max,
			fmod((_hue_offsets[polygon] as float + _get_time_in_seconds()) / duration, 1)
		)


func _get_time_in_seconds() -> float:
	return float(Time.get_ticks_msec()) / 1000
