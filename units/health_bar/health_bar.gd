extends ProgressBar


func _init() -> void:
	add_theme_stylebox_override("fill", get_theme_stylebox("fill").duplicate() as StyleBox)


func _enter_tree() -> void:
	update()


func update() -> void:
	var unit := get_parent() as Unit
	max_value = unit.get_stat(Unit.stats.HITPOINTS)
	value = unit.get_current_health()
	if ratio == 1:
		visible = false
	else:
		visible = true
		(get_theme_stylebox("fill") as StyleBoxFlat).bg_color = _get_color()


func _get_color() -> Color:
	# Colors used
	const full_color := Color(0, 0.75, 0) # color at full health
	const half_color := Color(0.9, 0.9, 0) # color at half health
	const zero_color := Color(0.75, 0, 0) # color at no health
	# Deriving color from linear regresson
	if ratio > 0.5:
		return half_color.lerp(full_color, inverse_lerp(0.5, 1, ratio))
	else:
		return zero_color.lerp(half_color, inverse_lerp(0, 0.5, ratio))
