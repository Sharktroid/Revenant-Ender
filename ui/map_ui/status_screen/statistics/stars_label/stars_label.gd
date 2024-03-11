@tool
extends HBoxContainer

var stars: float = 1:
	set(value):
		stars = value
		_update_stars()


func _update_stars() -> void:
	var stars_stylebox := (%"Stars Display" as Panel).get_theme_stylebox("panel") as StyleBoxTexture
	var star_size: Vector2i = stars_stylebox.texture.get_size()
	var number_label := $"Number Label" as Label
	var stars_width := %"Stars Width" as Control
	if star_size.x * stars > size.x:
		number_label.text = str(stars)
		number_label.visible = true
		stars_width.custom_minimum_size.x = star_size.x
	else:
		number_label.visible = false
		stars_width.custom_minimum_size.x = stars * star_size.x
