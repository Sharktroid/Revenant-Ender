## A scene that display combat information to the player.
## The information can be changed via an option.
class_name CombatPanel
extends GridContainer

## Emits true when the player presses select, and false when the player cancels out.
#signal completed(proceed: bool)

## The unit being displayed on the bottom.
var right_unit: Unit:
	set = _set_right_unit

var _left_unit: Unit
var _distance: int
var _focused: bool = false
var _current_weapons: Array[Weapon] = []
var _weapon_index: int = 0:
	set(value):
		_weapon_index = posmod(value, _current_weapons.size())
		_left_unit.equip_weapon(_get_current_weapon(), false)
		_update()
		if _focused:
			_left_unit.display_current_attack_tiles()
var _art_index: int = 0:
	set(value):
		_art_index = posmod(value, _left_unit.get_combat_arts(right_unit, _distance).size())
		_update()
var _old_weapon: Weapon
var _original_weapon: Weapon
var _on_info_display_complete: Callable
var _on_info_display_return: Callable
#@onready var _item_menu := %ItemMenu as _COMBAT_DISPLAY_SUBMENU
@onready var _left_name_panel := $LeftNamePanel as NamePanel
@onready var _art_label := $%ArtLabel as Label


func _ready() -> void:
	_left_name_panel.unit = _left_unit
	_update()
	var set_weapon_index: Callable = func(direction: float) -> void:
		_weapon_index += roundi(direction)
	add_child(SingleAxisInputController.new(set_weapon_index, &"left", &"right"))
	var set_art_index: Callable = func(direction: float) -> void: _art_index += roundi(direction)
	add_child(SingleAxisInputController.new(set_art_index, &"up", &"down"))


func _exit_tree() -> void:
	_left_unit.hide_current_attack_tiles()


## Creates a new instance.
static func instantiate(
	top: Unit,
	on_info_display_complete: Callable,
	on_info_display_return: Callable,
	bottom: Unit = null,
	focused: bool = false
) -> CombatPanel:
	const PACKED_SCENE: PackedScene = preload("res://ui/combat_panel/combat_panel.tscn")
	var scene := PACKED_SCENE.instantiate() as CombatPanel
	scene._left_unit = top
	scene._on_info_display_complete = on_info_display_complete
	scene._on_info_display_return = on_info_display_return
	if bottom:
		scene.right_unit = bottom
	# gdlint:ignore = private-method-call
	scene._set_focus(focused)
	return scene


func _input(event: InputEvent) -> void:
	var damage_scroll := $DamageScroll as ScrollContainer
	if event.is_action_pressed("select"):
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.BATTLE_SELECT)
		_on_info_display_complete.call()
		_set_focus(false)
		_left_unit.equip_weapon(_get_current_weapon())
	elif event.is_action_pressed("back"):
		if _old_weapon:
			_left_unit.equip_weapon(_old_weapon)
		_on_info_display_return.call()
		_set_focus(false)
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		_left_unit.equip_weapon(_original_weapon)
	elif event.is_action_pressed(&"scroll_up"):
		damage_scroll.scroll_vertical -= 8
	elif event.is_action_pressed(&"scroll_down"):
		damage_scroll.scroll_vertical += 8
	accept_event()


## Causes the node to be focused, allowing it to receive input and become opaque.
func focus() -> void:
	_set_focus(true)


func get_combat_art() -> CombatArt:
	return _left_unit.get_combat_arts(right_unit, _distance)[_art_index]


# Sets the focus.
func _set_focus(is_focused: bool) -> void:
	_focused = is_focused
	modulate.a = 1.0 if is_focused else 2.0 / 3
	if is_focused:
		_left_unit.display_current_attack_tiles()
		process_mode = PROCESS_MODE_INHERIT
	else:
		_left_unit.display_current_attack_tiles(true)
		process_mode = PROCESS_MODE_DISABLED


func _get_current_weapon() -> Weapon:
	return _current_weapons[_weapon_index]


func _get_index() -> int:
	if _left_unit.get_weapon() in _current_weapons:
		return _current_weapons.find(_left_unit.get_weapon())
	else:
		return 0


func _update() -> void:
	if right_unit and is_node_ready():
		var old_position: Vector2i = _left_unit.position
		_left_unit.position = _left_unit.get_path_last_pos()
		for child: Node in %Damage.get_children():
			child.queue_free()
		_left_name_panel.weapon = _left_unit.get_weapon()
		var combat := Combat.new(_left_unit, right_unit, _distance, get_combat_art())
		for arrow: AttackArrow in combat.create_attack_arrows():
			%Damage.add_child(arrow)
		var right_name_panel := $RightNamePanel as NamePanel

		right_name_panel.unit = right_unit
		right_name_panel.weapon = right_unit.get_weapon()
		const StatsPanel: GDScript = preload("res://ui/combat_panel/stats_panel/stats_panel.gd")
		($LeftStatsPanel as StatsPanel).update(_left_unit, combat, _distance)
		($RightStatsPanel as StatsPanel).update(right_unit, combat, _distance)
		_left_unit.position = old_position
		var combat_art: CombatArt = _left_unit.get_combat_arts(right_unit, _distance)[_art_index]
		_art_label.text = str(combat_art) if combat_art else "None"



func _set_right_unit(unit: Unit) -> void:
	right_unit = unit
	var path_end: Vector2i = _left_unit.get_unit_path().back()
	_distance = roundi(Utilities.get_tile_distance(path_end, right_unit.position))
	var is_in_range: Callable = func(weapon: Weapon) -> bool: return weapon.in_range(_distance)
	_current_weapons = _left_unit.get_all_weapon_modes().filter(is_in_range)
	_original_weapon = _left_unit.get_weapon()
	_weapon_index = _get_index()
	if not is_node_ready():
		await ready
	_left_name_panel.arrows = _current_weapons.size() > 1

	await get_tree().process_frame
	var combat_art_panel := %CombatArtPanel as PanelContainer
	var center: Vector2 = (combat_art_panel.size / 2).round()
	const VERTICAL_GAP: int = 5 + 3
	var vertical_offset: int = VERTICAL_GAP + round(combat_art_panel.size.y / 2)
	var top_arrow := %TopArrow as Sprite2D
	var bottom_arrow := %BottomArrow as Sprite2D
	if _left_unit.get_combat_arts(right_unit, _distance).size() > 1:
		top_arrow.position = center + Vector2(0, -(vertical_offset))
		bottom_arrow.position = center + Vector2(0, vertical_offset)
	else:
		top_arrow.visible = false
		bottom_arrow.visible = false
