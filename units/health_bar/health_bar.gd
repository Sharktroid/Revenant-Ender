extends ProgressBar


func _init() -> void:
	add_theme_stylebox_override("fill", get_theme_stylebox("fill").duplicate() as StyleBox)


func _enter_tree() -> void:
	update()


func update() -> void:
	var unit := get_parent() as Unit
	max_value = unit.get_stat(Unit.stats.HIT_POINTS)
	value = unit.current_health
	visible = ratio != 1
	if visible == true:
		(get_theme_stylebox("fill") as StyleBoxFlat).bg_color = _get_color()


func _get_color() -> Color:
	# Colors used
	const FULL_COLOR := Color(0, 0.75, 0) # color at full health
	const HALF_COLOR := Color(0.9, 0.9, 0) # color at half health
	const ZERO_COLOR := Color(0.75, 0, 0) # color at no health
	# Deriving color from linear regresson
	return (
			HALF_COLOR.lerp(FULL_COLOR, inverse_lerp(0.5, 1, ratio)) if ratio > 0.5
			else ZERO_COLOR.lerp(HALF_COLOR, inverse_lerp(0, 0.5, ratio))
	)
