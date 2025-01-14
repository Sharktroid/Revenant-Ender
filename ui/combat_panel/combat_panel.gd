## A scene that display combat information to the player.
## The information can be changed via an option.
class_name CombatInfoDisplay
extends GridContainer

## Emits true when the player presses select, and false when the player cancels out.
signal completed(proceed: bool)

## The unit being displayed on the bottom.
var right_unit: Unit:
	set(value):
		right_unit = value
		_update()

var _left_unit: Unit
var _distance: int
var _focused: bool = false
var _all_weapons: Array[Weapon]
var _current_weapons: Array[Weapon] = []
var _weapon_index: int = 0:
	set(value):
		_weapon_index = value
		_weapon_index = posmod(_weapon_index, _current_weapons.size())
		_left_unit.equip_weapon(_get_current_weapon(), false)
		_update()
		_left_unit.display_current_attack_tiles()
var _old_weapon: Weapon
var _original_weapon: Weapon
#@onready var _item_menu := %ItemMenu as _COMBAT_DISPLAY_SUBMENU
@onready var _left_name_panel := $LeftNamePanel as NamePanel


func _ready() -> void:
	_left_name_panel.unit = _left_unit
	_left_name_panel.arrows = _left_unit.get_weapons().size() > 1

	_all_weapons = _left_unit.get_weapons()

	_update()
	_original_weapon = _left_unit.get_weapon()
	_weapon_index = _left_unit.get_weapons().find(_left_unit.get_weapon())


func _exit_tree() -> void:
	_left_unit.hide_current_attack_tiles()


## Creates a new instance.
static func instantiate(top: Unit, bottom: Unit = null, focused: bool = false) -> CombatInfoDisplay:
	const PACKED_SCENE: PackedScene = preload("res://ui/combat_panel/combat_panel.tscn")
	var scene := PACKED_SCENE.instantiate() as CombatInfoDisplay
	scene._left_unit = top
	scene.right_unit = bottom
	# gdlint:ignore = private-method-call
	scene._set_focus(focused)
	return scene


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.BATTLE_SELECT)
		completed.emit(true)
		_left_unit.equip_weapon(_get_current_weapon())
	elif event.is_action_pressed("back"):
		if _old_weapon:
			_left_unit.equip_weapon(_old_weapon)
		completed.emit(false)
		_set_focus(false)
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		_left_unit.equip_weapon(_original_weapon)
	elif event.is_action_pressed("left") and not Input.is_action_pressed("right"):
		_weapon_index -= 1
	elif event.is_action_pressed("right"):
		_weapon_index += 1
	accept_event()


## Causes the node to be focused, allowing it to receive input and become opaque.
func focus() -> void:
	_set_focus(true)


# Sets the focus.
func _set_focus(is_focused: bool) -> void:
	_focused = is_focused
	modulate.a = 1.0 if is_focused else 0.5
	if is_node_ready():
		_update()
	if is_focused:
		_left_unit.display_current_attack_tiles()
		process_mode = PROCESS_MODE_INHERIT
	else:
		_left_unit.display_current_attack_tiles(true)
		process_mode = PROCESS_MODE_DISABLED


func _get_current_weapon() -> Weapon:
	return _current_weapons[_weapon_index]


func _update() -> void:
	if right_unit and is_node_ready():
		var path_end: Vector2i = _left_unit.get_unit_path().back()
		_distance = roundi(Utilities.get_tile_distance(path_end, right_unit.position))
		_current_weapons.assign(
			_all_weapons.filter(func(weapon: Weapon) -> bool: return weapon.in_range(_distance))
		)

		_left_name_panel.weapon = _left_unit.get_weapon()

		var right_name_panel := $RightNamePanel as NamePanel
		right_name_panel.unit = right_unit
		right_name_panel.weapon = right_unit.get_weapon()
		($LeftStatsPanel as StatsPanel).update(
			_left_unit,
			right_unit,
			_get_current_weapon(),
			right_unit.get_weapon(),
			_get_current_weapon().in_range(_distance)
		)
		($RightStatsPanel as StatsPanel).update(
			right_unit,
			_left_unit,
			right_unit.get_weapon(),
			_get_current_weapon(),
			right_unit.get_weapon().in_range(_distance)
		)
