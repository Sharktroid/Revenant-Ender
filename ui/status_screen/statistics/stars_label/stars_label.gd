@tool
extends HBoxContainer

var stars: float = 1:
	set(value):
		stars = value
		_update_stars()


func _ready() -> void:
	_update_stars()


func _update_stars() -> void:
	var star_size: Vector2i = %"Stars Display".get_theme_stylebox("panel").texture.get_size()
	if star_size.x * stars > size.x:
		$"Number Label".text = str(stars)
		$"Number Label".visible = true
		%"Stars Width".custom_minimum_size.x = star_size.x
	else:
		$"Number Label".visible = false
		%"Stars Width".custom_minimum_size.x = stars * star_size.x
