@tool
extends CenterContainer

var stars: float = 1


func _ready() -> void:
	_update_stars()


func _update_stars() -> void:
	var star_size: Vector2i = %"Stars Display".get_theme_stylebox("panel").texture.get_size()
	if star_size.x * stars > size.x:
		$"HBoxContainer/Number Label".text = str(stars)
		%"Stars Width".custom_minimum_size.x = star_size.x
	else:
		if not Engine.is_editor_hint():
			$"HBoxContainer/Number Label".queue_free()
		%"Stars Width".custom_minimum_size.x = stars * star_size.x
