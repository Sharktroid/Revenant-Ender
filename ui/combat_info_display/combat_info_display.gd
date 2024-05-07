@tool
extends PanelContainer

signal completed(proceed: bool)

const BLUE_COLORS: Array[Color] = [
	Color("5294D6"),
	Color("4284CE"),
	Color("5294D6"),
	Color("3973B5"),
	Color("427BBD"),
	Color("215AAD"),
	Color("315A9C"),
	Color("293984"),
]
const RED_COLORS: Array[Color] = [
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
var distance: int

var _weapons: Array[Weapon]
var _weapon_index: int = 0
var _old_weapon: Weapon


func _enter_tree() -> void:
	# Removes float rounding errors
	const LIGHT_BLUE := Color("5294D6")
	const DARK_BLUE := Color("315A9C")
	var top_unit_panel := %TopUnitPanel as PanelContainer
	(top_unit_panel.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = LIGHT_BLUE
	(top_unit_panel.get_node("Line2D") as Line2D).default_color = DARK_BLUE
	var bottom_unit_panel := %BottomUnitPanel as PanelContainer
	(bottom_unit_panel.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = DARK_BLUE
	(bottom_unit_panel.get_node("Line2D") as Line2D).default_color = LIGHT_BLUE

	_old_weapon = top_unit.get_current_weapon()
	for item: Item in top_unit.items:
		if item is Weapon:
			var weapon := item as Weapon
			if distance in weapon.get_range():
				_weapons.append(weapon)

	_update()
	GameController.add_to_input_stack(self)


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioPlayer.play_sound_effect(AudioPlayer.BATTLE_SELECT)
		queue_free()
		completed.emit(true)
	elif event.is_action_pressed("ui_cancel"):
		top_unit.equip_weapon(_old_weapon)
		completed.emit(false)
		queue_free()
	elif event.is_action_pressed("left") and not Input.is_action_pressed("right"):
		_weapon_index -= 1
		_update()
	elif event.is_action_pressed("right"):
		_weapon_index += 1
		_update()


func _get_current_weapon() -> Weapon:
	return _weapons[_weapon_index]


func _update() -> void:
	_weapon_index = posmod(_weapon_index, _weapons.size())
	top_unit.equip_weapon(_get_current_weapon())
	for half: String in ["Top", "Bottom"] as Array[String]:
		var is_top: bool = half == "Top"
		var current_unit: Unit = top_unit if is_top else bottom_unit
		var other_unit: Unit = bottom_unit if is_top else top_unit
		var weapon: Weapon = _weapons[_weapon_index] if is_top else bottom_unit.get_current_weapon()
		var format: Callable = func(input_string: String) -> String:
			return ("%" + half + input_string)
		(get_node(format.call("Name")) as Label).text = current_unit.unit_name
		(get_node(format.call("WeaponIcon")) as TextureRect).texture = weapon.icon
		(get_node(format.call("WeaponName")) as Label).text = weapon.name

		(get_node(format.call("HP")) as Label).text = str(current_unit.current_health)

		var in_range: bool = distance in weapon.get_range()
		(get_node(format.call("Damage")) as Label).text = (
			str(current_unit.get_damage(other_unit)) if in_range else "--"
		)
		(get_node(format.call("Hit")) as Label).text = (
			str(current_unit.get_hit_rate(other_unit)) if in_range else "--"
		)
		(get_node(format.call("CritDamage")) as Label).text = (
			str(current_unit.get_crit_damage(other_unit)) if in_range else "--"
		)
		(get_node(format.call("Crit")) as Label).text = (
			str(current_unit.get_crit_rate(other_unit)) if in_range else "--"
		)

		if current_unit.faction.color == Faction.Colors.RED:
			var shader_material: ShaderMaterial = (
				(get_node(format.call("UnitPanel")) as PanelContainer).material
			)
			var old_vectors: Array[Color] = []
			for color: Color in BLUE_COLORS:
				old_vectors.append(color)
			var new_vectors: Array[Color] = []
			for color: Color in RED_COLORS:
				new_vectors.append(color)
			shader_material.set_shader_parameter("old_colors", old_vectors)
			shader_material.set_shader_parameter("new_colors", new_vectors)
