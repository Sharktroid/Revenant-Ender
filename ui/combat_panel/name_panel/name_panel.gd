class_name NamePanel
extends PanelContainer

const _BLUE_COLORS: Array[Color] = [
	Color("5294D6"),
	Color("4284CE"),
	Color("3973B5"),
	Color("427BBD"),
	Color("215AAD"),
	Color("315A9C"),
	Color("293984"),
	Color("4279BD"),
	Color("31599C"),
]
const _RED_COLORS: Array[Color] = [
	Color("D65A63"),
	Color("CE4A4A"),
	Color("B54242"),
	Color("BD4A42"),
	Color("AD2929"),
	Color("9C4231"),
	Color("843129"),
	Color("BD4942"),
	Color("9C4131"),
]

## The unit on display.
var unit: Unit:
	set(value):
		unit = value
		(%UnitName as Label).text = unit.display_name
		if unit.faction.color != Faction.Colors.BLUE:
			var shader_material := material as ShaderMaterial
			shader_material.set_shader_parameter("old_colors", _BLUE_COLORS.duplicate())
			shader_material.set_shader_parameter(
				"new_colors", _get_new_colors(unit.faction.color).duplicate()
			)
## The weapon the unit is using.
var weapon: Weapon:
	set(value):
		weapon = value
		if weapon:
			(%ItemIcon as TextureRect).texture = weapon.get_icon()
		(%ItemNameLabel as Label).text = weapon.get_mode_name() if weapon else "--"
## Whether the weapon displays a pair of arrows.
var arrows: bool = false:
	set(value):
		arrows = value
		(%LeftArrow as Sprite2D).visible = arrows
		(%RightArrow as Sprite2D).visible = arrows


func _ready() -> void:
	material = material.duplicate(true)


func _get_new_colors(color: Faction.Colors) -> Array[Color]:
	match color:
		_:
			return _RED_COLORS
