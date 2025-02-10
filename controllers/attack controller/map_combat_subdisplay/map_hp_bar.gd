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

	var gradient := (gradient_stylebox.texture as GradientTexture2D).gradient
	gradient.set_color(0, _get_top_color(unit.faction.color))
	gradient.set_color(1, _get_bottom_color(unit.faction.color))

	unit.health_changed.connect(_on_unit_health_changed)
	_on_unit_health_changed()


func _get_top_color(faction_color: Faction.Colors) -> Color:
	match faction_color:
		Faction.Colors.RED:
			return Color("E36468")
		Faction.Colors.GREEN:
			var color := Color.GREEN
			color.s = 0.75
			return color
		Faction.Colors.PURPLE:
			var color := Color.PURPLE
			color.s = 0.75
			return color
		_:
			return Color("47B4D8")


func _get_bottom_color(faction_color: Faction.Colors) -> Color:
	match faction_color:
		Faction.Colors.RED:
			return Color("80363A")
		Faction.Colors.GREEN:
			var color := Color.GREEN
			color.v = 0.5
			return color
		Faction.Colors.PURPLE:
			var color := Color.PURPLE
			color.v = 0.5
			return color
		_:
			return Color("27647A")


## Updates the value displayed.
func _on_unit_health_changed() -> void:
	_hp_bar.value = unit.current_health
	(%HPLabel as Label).text = str(roundi(unit.current_health))
