class_name CombatInfoDisplay
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

const _COMBAT_DISPLAY_SUBMENU = preload("res://ui/combat_info_display/combat_display_submenu.gd")

var top_unit: Unit
var bottom_unit: Unit:
	set(value):
		bottom_unit = value
		_update()
var distance: int

var _focused: bool = false
var _all_weapons: Array[Weapon]
var _current_weapons: Array[Weapon] = []
var _weapon_index: int = 0:
	set(value):
		_weapon_index = value
		_weapon_index = posmod(_weapon_index, _current_weapons.size())
		_update()
		_item_menu.set_current_item_index(_weapon_index)
		top_unit.display_current_attack_tiles()
var _old_weapon: Weapon
@onready var _item_menu := %ItemMenu as _COMBAT_DISPLAY_SUBMENU


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

	for item: Item in top_unit.items:
		if item is Weapon:
			_all_weapons.append(item)

	_item_menu.weapon_selected.connect(_on_weapon_selected)
	_update()


func _exit_tree() -> void:
	top_unit.hide_current_attack_tiles()


static func instantiate(top: Unit, bottom: Unit = null, focused: bool = false) -> CombatInfoDisplay:
	const PACKED_SCENE: PackedScene = preload(
		"res://ui/combat_info_display/combat_info_display.tscn"
	)
	var scene := PACKED_SCENE.instantiate() as CombatInfoDisplay
	scene.top_unit = top
	scene.bottom_unit = bottom
	# gdlint:ignore = private-method-call
	scene._set_focus(focused)
	return scene


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.BATTLE_SELECT)
		queue_free()
		completed.emit(true)
	elif event.is_action_pressed("ui_cancel"):
		top_unit.equip_weapon(_old_weapon)
		completed.emit(false)
		_set_focus(false)
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
	elif event.is_action_pressed("up") and not Input.is_action_pressed("down"):
		_weapon_index -= 1
	elif event.is_action_pressed("down"):
		_weapon_index += 1


func focus() -> void:
	_set_focus(true)


func _set_focus(is_focused: bool) -> void:
	_focused = is_focused
	if is_node_ready():
		_update()
	if is_focused:
		if not GameController.get_current_input_node() == self:
			GameController.add_to_input_stack(self)
		top_unit.display_current_attack_tiles()
	else:
		if GameController.get_current_input_node() == self:
			GameController.remove_from_input_stack()
		top_unit.display_current_attack_tiles(true)


func _get_current_weapon() -> Weapon:
	return _current_weapons[_weapon_index]


func _update() -> void:
	if bottom_unit and is_node_ready():
		modulate.a = 1.0 if _focused else 2.0 / 3

		var cursor_to_left: bool = (
			CursorController.screen_position.x < (Utilities.get_screen_size().x as float / 2)
		)
		position.x = Utilities.get_screen_size().x - size.x if cursor_to_left else 0.0

		distance = roundi(
			Utilities.get_tile_distance(
				top_unit.get_unit_path().back() as Vector2i, bottom_unit.position
			)
		)

		_old_weapon = top_unit.get_current_weapon()
		_current_weapons = []
		for item: Item in _all_weapons:
			if item is Weapon:
				var weapon := item as Weapon
				if weapon.in_range(distance):
					_current_weapons.append(weapon)
		for node: Sprite2D in get_tree().get_nodes_in_group("arrows"):
			node.visible = _current_weapons.size() != 1 and _focused

		_item_menu.weapons = _current_weapons
		top_unit.equip_weapon(_get_current_weapon())
		if _focused:
			top_unit.display_current_attack_tiles()
		for half: String in ["Top", "Bottom"] as Array[String]:
			var is_top: bool = half == "Top"
			var current_unit: Unit = top_unit if is_top else bottom_unit
			var other_unit: Unit = bottom_unit if is_top else top_unit
			var weapon: Weapon = (
				_get_current_weapon() if is_top else bottom_unit.get_current_weapon()
			)
			var node_path: String = "%%{half}%s".format({"half": half})

			(get_node(node_path % "Name") as Label).text = current_unit.unit_name

			(get_node(node_path % "WeaponIcon") as TextureRect).texture = (
				weapon.get_icon() if weapon else null
			)
			(get_node(node_path % "WeaponName") as Label).text = weapon.get_name() if weapon else ""

			(get_node(node_path % "HP") as Label).text = str(current_unit.current_health)

			var in_range: bool = weapon and weapon.in_range(distance)
			(get_node(node_path % "Damage") as Label).text = (
				Utilities.float_to_string(current_unit.get_damage(other_unit)) if in_range else "--"
			)
			(get_node(node_path % "Hit") as Label).text = (
				str(current_unit.get_hit_rate(other_unit)) if in_range else "--"
			)
			(get_node(node_path % "CritDamage") as Label).text = (
				Utilities.float_to_string(current_unit.get_crit_damage(other_unit))
				if in_range
				else "--"
			)
			(get_node(node_path % "Crit") as Label).text = (
				str(current_unit.get_crit_rate(other_unit)) if in_range else "--"
			)

			var double_sprite := get_node(node_path % "Double") as Sprite2D
			double_sprite.visible = current_unit.can_follow_up(other_unit) and in_range

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


func _on_weapon_selected(weapon: Weapon) -> void:
	_weapon_index = _current_weapons.find(weapon)
