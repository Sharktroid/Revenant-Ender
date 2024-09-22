@tool
extends Line2D

## The amount of steps made in the interpolation. Higher value means more precise but slower.
const _STEPS: int = 50


func _ready() -> void:
	points = []
	for x in range(0, _STEPS + 1):
		add_point(Vector2(float(x) / _STEPS, 1 - _get_y(x)) * Vector2(Utilities.get_screen_size()))


## Mathematical function of x
func _get_y(x: float) -> float:
	if x < _STEPS * 0.8:
		return Tween.interpolate_value(
			0.5, 0.5, x, _STEPS * 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT
		)
	else:
		return 1
