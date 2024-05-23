extends SubViewportContainer

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
var bottom_unit: Unit:
	set(value):
		bottom_unit = value
		_update()
var distance: int

var _focused: bool = false
var _all_weapons: Array[Weapon]
var _current_weapons: Array[Weapon] = []
var _weapon_index: int = 0
var _old_weapon: Weapon


func _ready() -> void:
	# Removes float rounding errors
	const LIGHT_BLUE := Color("5294D6")
	const DARK_BLUE := Color("315A9C")
	var top_unit_panel := %TopUnitPanel as PanelContainer
	(top_unit_panel.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = LIGHT_BLUE
	(top_unit_panel.get_node("Line2D") as Line2D).default_color = DARK_BLUE
	var bottom_unit_panel := %BottomUnitPanel as PanelContainer
	(bottom_unit_panel.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = DARK_BLUE
	(bottom_unit_panel.get_node("Line2D") as Line2D).default_color = LIGHT_BLUE

	_animate_double_sprite(%TopDouble as Sprite2D)
	_animate_double_sprite(%BottomDouble as Sprite2D)

	modulate.a = 2.0 / 3
	visible = false

	for item: Item in top_unit.items:
		if item is Weapon:
			_all_weapons.append(item)


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioPlayer.play_sound_effect(AudioPlayer.BATTLE_SELECT)
		queue_free()
		completed.emit(true)
	elif event.is_action_pressed("ui_cancel"):
		top_unit.equip_weapon(_old_weapon)
		completed.emit(false)
		_set_focus(false)
	elif event.is_action_pressed("left") and not Input.is_action_pressed("right"):
		_weapon_index -= 1
		_update()
	elif event.is_action_pressed("right"):
		_weapon_index += 1
		_update()


func focus() -> void:
	_set_focus(true)


func _set_focus(is_focused: bool) -> void:
	_focused = is_focused
	modulate.a = 1.0 if is_focused else 2.0 / 3
	_update()
	if is_focused:
		GameController.add_to_input_stack(self)
	else:
		GameController.remove_from_input_stack()


func _get_current_weapon() -> Weapon:
	return _current_weapons[_weapon_index]


func _update() -> void:
	_old_weapon = top_unit.get_current_weapon()
	_current_weapons = []
	for item: Item in _all_weapons:
		if item is Weapon:
			var weapon := item as Weapon
			if weapon.in_range(distance):
				_current_weapons.append(weapon)
	for node: Sprite2D in get_tree().get_nodes_in_group("arrows"):
		node.visible = _current_weapons.size() != 1 and _focused

	_weapon_index = posmod(_weapon_index, _current_weapons.size())
	top_unit.equip_weapon(_get_current_weapon())
	for half: String in ["Top", "Bottom"] as Array[String]:
		var is_top: bool = half == "Top"
		var current_unit: Unit = top_unit if is_top else bottom_unit
		var other_unit: Unit = bottom_unit if is_top else top_unit
		var weapon: Weapon = _get_current_weapon() if is_top else bottom_unit.get_current_weapon()
		var node_path: String = "%%{half}%s".format({"half": half})

		(get_node(node_path % "Name") as Label).text = current_unit.unit_name

		(get_node(node_path % "WeaponIcon") as TextureRect).texture = (
			weapon.get_icon() if weapon else null
		)
		(get_node(node_path % "WeaponName") as Label).text = weapon.get_name() if weapon else ""

		(get_node(node_path % "HP") as Label).text = str(current_unit.current_health)

		var in_range: bool = weapon and weapon.in_range(distance)
		(get_node(node_path % "Damage") as Label).text = (
			str(current_unit.get_damage(other_unit)) if in_range else "--"
		)
		(get_node(node_path % "Hit") as Label).text = (
			str(current_unit.get_hit_rate(other_unit)) if in_range else "--"
		)
		(get_node(node_path % "CritDamage") as Label).text = (
			str(current_unit.get_crit_damage(other_unit)) if in_range else "--"
		)
		(get_node(node_path % "Crit") as Label).text = (
			str(current_unit.get_crit_rate(other_unit)) if in_range else "--"
		)

		var double_sprite := get_node(node_path % "Double") as Sprite2D
		double_sprite.visible = current_unit.can_follow_up(other_unit)

		if current_unit.faction.color == Faction.Colors.RED:
			var shader_material: ShaderMaterial = (
				(get_node(node_path % "UnitPanel") as PanelContainer).material
			)
			var old_vectors: Array[Color] = []
			for color: Color in BLUE_COLORS:
				old_vectors.append(color)
			var new_vectors: Array[Color] = []
			for color: Color in RED_COLORS:
				new_vectors.append(color)
			shader_material.set_shader_parameter("old_colors", old_vectors)
			shader_material.set_shader_parameter("new_colors", new_vectors)


func _animate_double_sprite(sprite: Sprite2D) -> void:
	if not sprite.is_node_ready():
		await sprite.ready
	var tween: Tween = sprite.create_tween()
	tween.set_loops()
	tween.set_speed_scale(60)
	tween.tween_property(sprite, "position:y", sprite.position.y - 3, 9)
	tween.tween_property(sprite, "position:x", sprite.position.x - 7, 21)
	tween.tween_property(sprite, "position:y", sprite.position.y, 9)
	tween.tween_property(sprite, "position:x", sprite.position.x, 21)
