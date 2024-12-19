@tool
extends HBoxContainer

var stars: float = 1:
	set(value):
		stars = value
		_update_stars()


func _update_stars() -> void:
	var star_size: Vector2i = (
		((%StarsDisplay as Panel).get_theme_stylebox("panel") as StyleBoxTexture).texture.get_size()
	)
	var number_label := $NumberLabel as Label
	var stars_width := %StarsWidth as Control
	if star_size.x * stars > size.x:
		number_label.text = str(stars)
		number_label.visible = true
		stars_width.custom_minimum_size.x = star_size.x
	else:
		number_label.visible = false
		stars_width.custom_minimum_size.x = stars * star_size.x
