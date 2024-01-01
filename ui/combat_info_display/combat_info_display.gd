@tool
extends PanelContainer
const blue_colors: Array[Color] = [
	Color("5294D6"),
	Color("4284CE"),
	Color("5294D6"),
	Color("3973B5"),
	Color("427BBD"),
	Color("215AAD"),
	Color("315A9C"),
	Color("293984"),
]
const red_colors: Array[Color] = [
	Color("D65A63"),
	Color("CE4A4A"),
	Color("D65A63"),
	Color("B54242"),
	Color("BD4A42"),
	Color("AD2929"),
	Color("9C4231"),
	Color("843129"),
]

var _top_unit: Unit = preload("res://units/characters/binding blade/marcus/marcus.tscn").instantiate()
var _bottom_unit: Unit = preload("res://units/characters/binding blade/roy/roy.tscn").instantiate()


func _ready() -> void:
	add_child(_top_unit)
	add_child(_bottom_unit)
	_top_unit.visible = false
	_bottom_unit.visible = false

	%"Top Name".text = _top_unit.unit_name
	%"Bottom Name".text = _bottom_unit.unit_name
	%"Top Weapon Icon".texture = _top_unit.get_current_weapon().icon
	%"Bottom Weapon Icon".texture = _bottom_unit.get_current_weapon().icon
	%"Top Weapon Name".text = _top_unit.get_current_weapon().name
	%"Bottom Weapon Name".text = _bottom_unit.get_current_weapon().name

	%"Top HP".text = str(_top_unit.get_current_health())
	%"Bottom HP".text = str(_bottom_unit.get_current_health())
	%"Top Damage".text = str(_top_unit.get_damage(_bottom_unit))
	%"Bottom Damage".text = str(_bottom_unit.get_damage(_top_unit))
	%"Top Hit".text = str(_top_unit.get_hit_rate(_bottom_unit))
	%"Bottom Hit".text = str(_bottom_unit.get_hit_rate(_top_unit))
	%"Top Crit Damage".text = str(_top_unit.get_crit_damage(_bottom_unit))
	%"Bottom Crit Damage".text = str(_bottom_unit.get_crit_damage(_top_unit))
	%"Top Crit".text = str(_top_unit.get_crit_rate(_bottom_unit))
	%"Bottom Crit".text = str(_bottom_unit.get_crit_rate(_top_unit))

	var shader_material: ShaderMaterial = %"Bottom Unit".material
	var blue_vectors: Array[Vector3] = []
	for color: Color in blue_colors:
		blue_vectors.append(Vector3(color.r, color.g, color.b) * 255)
	var red_vectors: Array[Vector3] = []
	for color: Color in red_colors:
		red_vectors.append(Vector3(color.r, color.g, color.b) * 255)
	shader_material.set_shader_parameter("old_colors", blue_vectors)
	shader_material.set_shader_parameter("new_colors", red_vectors)
