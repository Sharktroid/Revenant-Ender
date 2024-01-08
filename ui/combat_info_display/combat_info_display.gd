@tool
extends PanelContainer

signal complete(proceed: bool)

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

var top_unit: Unit
var bottom_unit: Unit


func _ready() -> void:
	# Removes float rounding errors
	var light_blue := Color("5294D6")
	var dark_blue := Color("315A9C")
	%"Top Unit Panel".get_theme_stylebox("panel").bg_color = light_blue
	%"Top Unit Panel".get_node("Line2D").default_color = dark_blue
	%"Bottom Unit Panel".get_theme_stylebox("panel").bg_color = dark_blue
	%"Bottom Unit Panel".get_node("Line2D").default_color = light_blue

	for half: String in ["Top", "Bottom"]:
		var current_unit: Unit
		var other_unit: Unit
		var format: Callable = func(input_string: String) -> String:
			return ("%" + half + " " + input_string)
		match half:
			"Top":
				current_unit = top_unit
				other_unit = bottom_unit
			"Bottom":
				current_unit = bottom_unit
				other_unit = top_unit
		get_node(format.call("Name") as String).text = current_unit.unit_name
		get_node(format.call("Weapon Icon") as String).texture = \
				current_unit.get_current_weapon().icon
		get_node(format.call("Weapon Name") as String).text = \
				current_unit.get_current_weapon().name

		get_node(format.call("HP") as String).text = str(current_unit.get_current_health())
		get_node(format.call("Damage") as String).text = str(current_unit.get_damage(other_unit))
		get_node(format.call("Hit") as String).text = str(current_unit.get_hit_rate(other_unit))
		get_node(format.call("Crit Damage") as String).text = \
				str(current_unit.get_crit_damage(other_unit))
		get_node(format.call("Crit") as String).text = str(current_unit.get_crit_rate(other_unit))

		if current_unit.get_faction().color == Faction.colors.RED:
			var shader_material: ShaderMaterial = get_node(format.call("Unit Panel") as String).material
			var old_vectors: Array[Vector3] = []
			for color: Color in blue_colors:
				old_vectors.append(Vector3(color.r, color.g, color.b) * 255)
			var new_vectors: Array[Vector3] = []
			for color: Color in red_colors:
				new_vectors.append(Vector3(color.r, color.g, color.b) * 255)
			shader_material.set_shader_parameter("old_colors", old_vectors)
			shader_material.set_shader_parameter("new_colors", new_vectors)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		queue_free()
		emit_signal("complete", true)
		accept_event()
	if event.is_action_pressed("ui_cancel"):
		emit_signal("complete", false)
		queue_free()
		accept_event()
