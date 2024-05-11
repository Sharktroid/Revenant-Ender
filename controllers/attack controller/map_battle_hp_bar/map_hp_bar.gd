class_name MapHPBar
extends ReferenceRect

var unit: Unit
var _bg_gradient: Panel
@onready var _hp_bar := %HPBar as ProgressBar


func _ready() -> void:
	_bg_gradient = %BGGradient as Panel
	_hp_bar.max_value = unit.get_stat(Unit.Stats.HIT_POINTS)
	(%Name as Label).text = unit.unit_name
	_bg_gradient.add_theme_stylebox_override(
		"panel", _get_gradient_stylebox().duplicate(true) as StyleBoxTexture
	)


func _process(_delta: float) -> void:
	if is_instance_valid(unit):
		_hp_bar.value = unit.current_health
		(%HPLabel as Label).text = str(roundi(_hp_bar.value))
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
		_get_gradient().set_color(0, top_color)
		_get_gradient().set_color(1, bottom_color)


func _get_gradient() -> Gradient:
	return (_get_gradient_stylebox().texture as GradientTexture2D).gradient


func _get_gradient_stylebox() -> StyleBoxTexture:
	return _bg_gradient.get_theme_stylebox("panel") as StyleBoxTexture
