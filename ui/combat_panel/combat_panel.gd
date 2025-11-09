## A scene that display combat information to the player.
## The information can be changed via an option.
class_name CombatInfoDisplay
extends GridContainer

## Emits true when the player presses select, and false when the player cancels out.
#signal completed(proceed: bool)

## The unit being displayed on the bottom.
var right_unit: Unit:
	set(value):
		right_unit = value
		var path_end: Vector2i = _left_unit.get_unit_path().back()
		_distance = roundi(Utilities.get_tile_distance(path_end, right_unit.position))
		var is_in_range: Callable = func(weapon: Weapon) -> bool: return weapon.in_range(_distance)
		_current_weapons = _left_unit.get_all_weapon_modes().filter(is_in_range)
		_original_weapon = _left_unit.get_weapon()
		_weapon_index = _get_index()
		if not is_node_ready():
			await ready
		_left_name_panel.arrows = _current_weapons.size() > 1

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
		if _focused:
			_left_unit.display_current_attack_tiles()
var _old_weapon: Weapon
var _original_weapon: Weapon
var _on_info_display_complete: Callable
var _on_info_display_return: Callable
#@onready var _item_menu := %ItemMenu as _COMBAT_DISPLAY_SUBMENU
@onready var _left_name_panel := $LeftNamePanel as NamePanel


func _ready() -> void:
	_left_name_panel.unit = _left_unit
	_update()
	var set_weapon_index: Callable = func(direction: float) -> void:
		_weapon_index += roundi(direction)
	add_child(SingleAxisInputController.new(set_weapon_index, &"up", &"down"))


func _exit_tree() -> void:
	_left_unit.hide_current_attack_tiles()


## Creates a new instance.
static func instantiate(
	top: Unit,
	on_info_display_complete: Callable,
	on_info_display_return: Callable,
	bottom: Unit = null,
	focused: bool = false
) -> CombatInfoDisplay:
	const PACKED_SCENE: PackedScene = preload("res://ui/combat_panel/combat_panel.tscn")
	var scene := PACKED_SCENE.instantiate() as CombatInfoDisplay
	scene._left_unit = top
	scene._on_info_display_complete = on_info_display_complete
	scene._on_info_display_return = on_info_display_return
	if bottom:
		scene.right_unit = bottom
	# gdlint:ignore = private-method-call
	scene._set_focus(focused)
	return scene


func _input(event: InputEvent) -> void:
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
	accept_event()


## Causes the node to be focused, allowing it to receive input and become opaque.
func focus() -> void:
	_set_focus(true)


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
		#Utilities.start_profiling()
		for child: Node in $Damage.get_children():
			child.queue_free()
		#Utilities.profiler_checkpoint()
		_left_name_panel.weapon = _left_unit.get_weapon()
		#Utilities.profiler_checkpoint()
		var attack_queue: Array[AttackController.CombatStage] = AttackController.get_attack_queue(
			_left_unit, _distance, right_unit
		)
		#Utilities.profiler_checkpoint()
		_create_attack_arrows(attack_queue)
		var right_name_panel := $RightNamePanel as NamePanel

		right_name_panel.unit = right_unit
		right_name_panel.weapon = right_unit.get_weapon()
		#Utilities.profiler_checkpoint()
		var get_total_damage: Callable = func(
			accumulator: float, attack: AttackController.CombatStage, unit: Unit
		) -> float:
			if attack.attacker == unit:
				accumulator += attack.get_damage(false, attack_queue[0] == attack)
			return accumulator
		#Utilities.profiler_checkpoint()
		const StatsPanel: GDScript = preload("res://ui/combat_panel/stats_panel/stats_panel.gd")
		($LeftStatsPanel as StatsPanel).update(
			_left_unit,
			right_unit,
			attack_queue.reduce(get_total_damage.bind(right_unit), 0) as float,
			_distance
		)
		#Utilities.profiler_checkpoint()
		($RightStatsPanel as StatsPanel).update(
			right_unit,
			_left_unit,
			attack_queue.reduce(get_total_damage.bind(_left_unit), 0) as float,
			_distance
		)
		#Utilities.finish_profiling()
		_left_unit.position = old_position


func _create_attack_arrows(attack_queue: Array[AttackController.CombatStage]) -> void:
	var left_sum: float = 0
	var right_sum: float = 0
	var left_critical_sum: float = 0
	var right_critical_sum: float = 0
	for attack: AttackController.CombatStage in attack_queue:
		#Utilities.start_profiling()
		var initiation: bool = attack == attack_queue[0]
		if attack.attacker == _left_unit:
			left_sum += attack.get_damage(false, initiation)
			left_critical_sum += attack.get_damage(true, initiation)
		else:
			right_sum += attack.get_damage(false, initiation)
			right_critical_sum += attack.get_damage(true, initiation)
		#Utilities.profiler_checkpoint()
		const DIRS = AttackArrow.DIRECTIONS
		var direction: AttackArrow.DIRECTIONS = (
			DIRS.RIGHT if attack.attacker == _left_unit else DIRS.LEFT
		)
		#Utilities.profiler_checkpoint()
		var event: AttackArrow.EVENTS = _get_event(
			left_sum if attack.attacker == _left_unit else right_sum,
			left_critical_sum if attack.attacker == _left_unit else right_critical_sum,
			attack
		)
		#Utilities.profiler_checkpoint()
		var attack_arrow := AttackArrow.instantiate(
			direction,
			attack.get_damage(false, initiation, false),
			attack.get_damage(true, initiation, false),
			event,
			attack.attacker.faction.color
		)
		#Utilities.profiler_checkpoint()
		$Damage.add_child(attack_arrow)
		#Utilities.finish_profiling()


func _get_event(
	current_sum: float, current_critical_sum: float, attack: AttackController.CombatStage
) -> AttackArrow.EVENTS:
	if attack.attacker.get_hit_rate(attack.defender) <= 0:
		return AttackArrow.EVENTS.MISS
	elif current_sum >= attack.defender.current_health:
		return AttackArrow.EVENTS.KILL
	elif current_critical_sum >= attack.defender.current_health:
		return AttackArrow.EVENTS.CRIT_KILL
	return AttackArrow.EVENTS.NONE
