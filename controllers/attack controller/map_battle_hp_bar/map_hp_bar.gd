class_name MapHPBar
extends Control


var unit: Unit


func _ready() -> void:
	%"HP Bar".max_value = unit.get_stat(Unit.stats.HITPOINTS)
	%Name.text = unit.name
	var panel: StyleBoxTexture = %"BG Gradient".get_theme_stylebox("panel").duplicate(true)
	%"BG Gradient".add_theme_stylebox_override("panel", panel)


func _process(_delta: float) -> void:
	if is_instance_valid(unit):
		(%"HP Bar" as ProgressBar).value = unit.get_current_health()
		%"HP Label".text = str(%"HP Bar".value)
		var top_color: Color
		var bottom_color: Color
		match unit.get_faction().color:
			Faction.colors.BLUE:
				top_color = Color("47B4D8")
				bottom_color = Color("27647A")
			Faction.colors.RED:
				top_color = Color("E36468")
				bottom_color = Color("80363A")
			Faction.colors.GREEN:
				top_color = Color.GREEN
				top_color.s = 0.75
				top_color = Color.GREEN
				top_color.v = 0.5
			Faction.colors.PURPLE:
				top_color = Color.PURPLE
				top_color.s = 0.75
				top_color = Color.PURPLE
				top_color.v = 0.5
		_get_gradient().set_color(0, top_color)
		_get_gradient().set_color(1, bottom_color)


func _get_gradient() -> Gradient:
	return %"BG Gradient".get_theme_stylebox("panel").texture.gradient
