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
		var path_end: Vector2i = _left_unit.get_unit_path().back()
		_distance = roundi(Utilities.get_tile_distance(path_end, right_unit.position))
		var is_in_range: Callable = func(weapon: Weapon) -> bool: return weapon.in_range(_distance)
		_current_weapons.assign(_left_unit.get_weapons().filter(is_in_range))
		_original_weapon = _left_unit.get_weapon()
		_weapon_index = _get_index()
		_update()

var _left_unit: Unit
var _distance: int
var _focused: bool = false
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
	_update()


func _exit_tree() -> void:
	_left_unit.hide_current_attack_tiles()


## Creates a new instance.
static func instantiate(top: Unit, bottom: Unit = null, focused: bool = false) -> CombatInfoDisplay:
	const PACKED_SCENE: PackedScene = preload("res://ui/combat_panel/combat_panel.tscn")
	var scene := PACKED_SCENE.instantiate() as CombatInfoDisplay
	scene._left_unit = top
	if bottom:
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
	modulate.a = 1.0 if is_focused else 2.0/3
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
		_left_name_panel.weapon = _left_unit.get_weapon()

		var right_name_panel := $RightNamePanel as NamePanel
		right_name_panel.unit = right_unit
		right_name_panel.weapon = right_unit.get_weapon()
		($LeftStatsPanel as StatsPanel).update(
			_left_unit,
			right_unit,
			_get_current_weapon(),
			right_unit.get_weapon(),
			_distance
		)
		($RightStatsPanel as StatsPanel).update(
			right_unit,
			_left_unit,
			right_unit.get_weapon(),
			_get_current_weapon(),
			_distance
		)

		for child: Node in $Damage.get_children():
			child.queue_free()
		var left_sum: float = 0
		var right_sum: float = 0
		var left_critical_sum: float = 0
		var right_critical_sum: float = 0
		for attack: AttackController.CombatStage in AttackController.get_attack_queue(
			_left_unit, _distance, right_unit
		):
			var damage: float = attack.attacker.get_damage(attack.defender)
			var get_critical_damage: Callable = func() -> float:
				if attack.attacker.get_crit_rate(attack.defender) > 0:
					return attack.attacker.get_crit_damage(attack.defender)
				else:
					return 0.0
			if attack.attacker == _left_unit:
				left_sum += damage
				left_critical_sum += get_critical_damage.call()
			else:
				right_sum += damage
				right_critical_sum += get_critical_damage.call()
			var direction: AttackArrow.DIRECTIONS = (
				AttackArrow.DIRECTIONS.RIGHT
				if attack.attacker == _left_unit
				else AttackArrow.DIRECTIONS.LEFT
			)
			var get_event: Callable = func() -> AttackArrow.EVENTS:
				var current_sum: float = left_sum if attack.attacker == _left_unit else right_sum
				var current_critical_sum: float = (
					left_critical_sum if attack.attacker == _left_unit else right_critical_sum
				)
				if current_sum >= attack.defender.current_health:
					return AttackArrow.EVENTS.KILL
				elif current_critical_sum >= attack.defender.current_health:
					return AttackArrow.EVENTS.CRIT_KILL
				return AttackArrow.EVENTS.NONE
			var attack_arrow := AttackArrow.instantiate(
				direction,
				attack.attacker.get_damage(attack.defender),
				attack.attacker.get_crit_damage(attack.defender),
				get_event.call() as AttackArrow.EVENTS,
				attack.attacker.faction.color
			)
			$Damage.add_child(attack_arrow)
