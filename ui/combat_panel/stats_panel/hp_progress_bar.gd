extends NumericProgressBar


func _update() -> void:
	super()
	if _progress_bar_yellow.size.x == 1.0:
		await _progress_bar_yellow.resized
	_value_label.position.x = (
		_progress_bar_yellow.position.x
		+ _progress_bar_yellow.ratio * _progress_bar_yellow.size.x
	)
	var size_offset: float = _value_label.size.x + 3
	if _value_label.position.x > size_offset:
		_value_label.position.x -= size_offset


func _get_theme_variation() -> StringName:
	return &"BlueLabel"
