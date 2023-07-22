extends Node2D

var _percent: float = 100 : set = set_percent


func _ready() -> void:
	$Meter.texture = $Meter.texture.duplicate()
	$Meter.texture.gradient = $Meter.texture.gradient.duplicate()
	update_meter()


func set_percent(new_percent: float) -> void:
	## Sets the displayed percent with "new_percent"
	_percent = clamp(new_percent, 0, 100)
	update_meter()
	$Meter.texture.width = max(round(_percent * 0.14), 1)


func get_color(num: float) -> Color:
	## Gets the color for the meter
	## num: the percent of health
	# Colors used
	var full_color = Color(0, 0.75, 0) # color at full health
	var half_color = Color(0.9, 0.9, 0) # color at half health
	var zero_color = Color(0.75, 0, 0) # color at no health
	var final_color = Color()
	# Deriving color from linear regresson
	if num > 50:
		for i in 3:
			final_color[i] = (full_color[i] - half_color[i])/50 * (num - 50) + half_color[i]
	else:
		for i in 3:
			final_color[i] = (half_color[i] - zero_color[i])/50 * num + zero_color[i]
	return final_color


func update_meter() -> void:
	## Updates the color and visibility of the meter
	if _percent == 100:
		visible = false
	else:
		visible = true
	$Meter.texture.gradient.colors = [get_color(_percent)]
