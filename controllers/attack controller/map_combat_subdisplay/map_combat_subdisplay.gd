## Class that displays a [Unit]'s HP for a map animation.
class_name MapHPBar
extends ReferenceRect

## The [Unit] whose health is being displayed.
var unit: Unit
@onready var _hp_bar := %HPBar as ProgressBar


func _ready() -> void:
	var bg_gradient := %BGGradient as Panel
	var gradient_stylebox := (
		bg_gradient.get_theme_stylebox("panel").duplicate(true) as StyleBoxTexture
	)
	_hp_bar.max_value = unit.get_hit_points()
	(%Name as Label).text = unit.display_name
	bg_gradient.add_theme_stylebox_override("panel", gradient_stylebox as StyleBoxTexture)

	#region set_color
	var top_color: Color
	var bottom_color: Color
	match unit.faction.color:
		Faction.Colors.BLUE:
			top_color = Color("47B4D8")
			bottom_color = Color("27647A")
		Faction.Colors.RED:
			top_color = Color("E36468")
			bottom_color = Color("80363A")
		Faction.Colors.GREEN:
			top_color = Color.GREEN
			top_color.s = 0.75
			top_color = Color.GREEN
			top_color.v = 0.5
		Faction.Colors.PURPLE:
			top_color = Color.PURPLE
			top_color.s = 0.75
			top_color = Color.PURPLE
			top_color.v = 0.5

	var gradient := (gradient_stylebox.texture as GradientTexture2D).gradient
	gradient.set_color(0, top_color)
	gradient.set_color(1, bottom_color)
	#endregion

	unit.health_changed.connect(_on_unit_health_changed)
	_on_unit_health_changed()


## Updates the value displayed.
func _on_unit_health_changed() -> void:
	_hp_bar.value = unit.current_health
	(%HPLabel as Label).text = str(roundi(unit.current_health))
