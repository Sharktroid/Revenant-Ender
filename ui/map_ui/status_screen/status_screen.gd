## The menu that is displayed
class_name StatusScreen
extends Control
#gdlint: ignore = enum-name
enum _Directions { UP, DOWN }

## Class for the statistics tab
const _STATISTICS = preload("res://ui/map_ui/status_screen/statistics/statistics.gd")
## Class for the item screen tab
const _ITEM_SCREEN = preload("res://ui/map_ui/status_screen/item_screen/item_screen.gd")

## The unit whose stats are currently on display.
var observing_unit := Unit.new()

## When true, scrolling is disabled.
var _scroll_lock: bool = false
## The [Portrait] currently on display.
@onready var _portrait := %Portrait as Portrait
## The [TabContainer] that contains the submenus.
@onready var _menu_tabs := $MenuScreen/MenuTabs as TabContainer
## The menu that displays the [member observing_unit]'s stats.
@onready var _statistics := $MenuScreen/MenuTabs/Statistics as _STATISTICS
## The menu that displays the [member observing_unit]'s items.
@onready var _items := $MenuScreen/MenuTabs/Items as _ITEM_SCREEN

## The index of the tab that was last displayed.
static var previous_tab: int = 0


func _ready() -> void:
	_menu_tabs.current_tab = previous_tab
	(_menu_tabs.get_child(0, true) as TabBar).mouse_filter = Control.MOUSE_FILTER_PASS

	_update.call_deferred()

	(%AttackLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.ATTACK
	(%ASLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.ATTACK_SPEED
	(%HitLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.HIT
	(%AvoidLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.AVOID
	(%CritLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.CRIT
	(%CriticalAvoidLabelDescription as HelpContainer).help_description += (
		"\n%s" % Formulas.CRITICAL_AVOID
	)

	var tab_switch: Callable = func(direction: float) -> void:
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.TAB_SWITCH)
		Utilities.switch_tab(_menu_tabs as TabContainer, roundi(direction))
	add_child(SingleAxisInputController.new(tab_switch, &"left", &"right"))

	var scroll: Callable = func(direction: float) -> void:
		observing_unit = MapController.map.get_unit_relative(observing_unit, roundi(direction))
		await _move(-roundi(direction))
	add_child(ScrollAxisInputController.new(scroll, &"up", &"down", 1))


func _exit_tree() -> void:
	previous_tab = _menu_tabs.current_tab
	CursorController.enable()
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)


## Instantiates a [StatusScreen] from a [PackedScene].
static func instantiate(unit: Unit) -> StatusScreen:
	var scene: StatusScreen = (
		preload("res://ui/map_ui/status_screen/status_screen.tscn").instantiate()
	)
	scene.observing_unit = unit
	return scene


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		queue_free()


## Updates internal variables
func _update() -> void:
	_statistics.observing_unit = observing_unit
	_items.observing_unit = observing_unit
	_update_portrait()

	(%UnitName as Label).text = observing_unit.display_name
	(%UnitDescription as HelpContainer).help_description = observing_unit.unit_description
	(%ClassName as Label).text = observing_unit.unit_class.resource_name
	(%ClassDescription as HelpContainer).help_description = (
		observing_unit.unit_class.get_description()
	)

	_set_label_text_to_number(%CurrentLevel as Label, observing_unit.level)
	_set_label_text_to_number(%MaxLevel as Label, observing_unit.LEVEL_CAP)
	_set_label_text_to_number(%Current as Label, roundi(observing_unit.current_health))
	_set_label_text_to_number(%MaxHitPoints as Label, observing_unit.get_hit_points())
	var hp_help := %HitPointsStatHelp as HelpContainer
	hp_help.help_table = observing_unit.get_stat_table(Unit.Stats.HIT_POINTS)
	_set_label_text_to_number(%EXPPercent as Label, observing_unit.get_exp_percent())
	(%EXPStatHelp as HelpContainer).help_description = _get_exp_stat_help()

	_update_offensive_parameters()

	(%ASDescription as HelpContainer).help_description = Formulas.ATTACK_SPEED.format(
		observing_unit
	)
	_set_label_text_to_number(%ASValue as Label, observing_unit.get_attack_speed())
	(%AvoidDescription as HelpContainer).help_description = Formulas.AVOID.format(observing_unit)
	_set_label_text_to_number(%AvoidValue as Label, observing_unit.get_avoid())
	(%CriticalAvoidDescription as HelpContainer).help_description = Formulas.CRITICAL_AVOID.format(
		observing_unit
	)
	_set_label_text_to_number(%CriticalAvoidValue as Label, observing_unit.get_critical_avoid())
	(%RangeValue as RichTextLabel).text = _get_range_value()

	_update_tab()


func _update_portrait() -> void:
	var old_portrait: Portrait = _portrait
	var new_portrait: Portrait = observing_unit.get_portrait()
	new_portrait.position = observing_unit.get_portrait_offset()
	old_portrait.replace_by(new_portrait)
	new_portrait.set_emotion(Portrait.Emotions.NONE)
	_portrait = new_portrait
	old_portrait.queue_free()


func _update_offensive_parameters() -> void:
	(%AttackDescription as HelpContainer).help_description = _get_attack_description()
	var attack_label := %AttackValue as Label
	var hit_description := %HitDescription as HelpContainer
	var hit_label := %HitValue as Label
	var crit_description := %CritDescription as HelpContainer
	var crit_label := %CritValue as Label
	if observing_unit.get_weapon():
		if observing_unit.get_weapon() is Spear:
			attack_label.text = "{initiation}/{standard}".format(
				{"initiation": observing_unit.get_attack(true),"standard": observing_unit.get_attack(false)}
			)
		else:
			_set_label_text_to_number(attack_label, observing_unit.get_attack(false))
		hit_description.help_description = Formulas.HIT.format(observing_unit)
		_set_label_text_to_number(hit_label, observing_unit.get_hit())
		crit_description.help_description = Formulas.CRIT.format(observing_unit)
		_set_label_text_to_number(crit_label, observing_unit.get_crit())
	else:
		attack_label.text = "--"
		hit_description.help_description = "--"
		hit_label.text = "--"
		crit_description.help_description = "--"
		crit_label.text = "--"


func _get_attack_description() -> String:
	if observing_unit.get_weapon():
		var format_dictionary: Dictionary[String, float] = {
			"attack": observing_unit.get_current_attack(),
			"might": observing_unit.get_weapon().get_might()
		}
		return "{attack} + {might}".format(format_dictionary)
	return "--"


func _get_range_value() -> String:
	if observing_unit.get_weapon():
		var range_text: String = observing_unit.get_weapon().get_range_text().replace(
			"-", " [color={yellow}]-[/color] ".format({"yellow": Utilities.FONT_YELLOW})
		)
		return "[color={blue}]{text}[/color]".format(
			{"blue": Utilities.FONT_BLUE, "text": range_text}
		)
	return "--"


func _get_exp_stat_help() -> String:
	var current_exp: float = observing_unit.get_current_exp()
	var next_level_exp: float = Unit.get_exp_to_level(observing_unit.level + 1)
	const EXP_DESCRIPTION: String = (
		"[center][color={blue}]{current_exp}[color={yellow}]/"
		+ "[/color]{next_level_exp}[/color][/center]\n"
		+ "[color={blue}]{remaining_exp}[/color] to next level\n"
		+ "Total exp: [color={blue}]{total_exp}[/color]"
	)
	var replacements: Dictionary[String, String] = {
		"blue": Utilities.FONT_BLUE,
		"yellow": Utilities.FONT_YELLOW,
		"current_exp": str(roundi(current_exp)),
		"next_level_exp": str(roundi(next_level_exp)),
		"remaining_exp": str(roundi(next_level_exp - current_exp)),
		"total_exp": str(roundi(observing_unit.total_exp)),
	}
	return EXP_DESCRIPTION.format(replacements)


## Updates the current tab.
func _update_tab() -> void:
	var constant_labels: Array[Control] = [%UnitDescription]
	var get_left_node: Callable = func(child: Node) -> Control:
		return child if child is HelpContainer else child.get_child(1)
	constant_labels.append_array(%HighStatsContainer.get_children().map(get_left_node))
	var tab_controls: Array[Control] = []
	match _menu_tabs.current_tab:
		0:
			tab_controls.assign(_statistics.get_left_controls())
		1:
			tab_controls.assign(_get_leftmost_item_tab_controls())
	await get_tree().process_frame
	for control: Control in constant_labels:
		control.focus_neighbor_right = control.get_path_to(
			Utilities.get_control_within_height(control, tab_controls)
		)
	for control: Control in tab_controls:
		control.focus_neighbor_left = control.get_path_to(
			Utilities.get_control_within_height(control, constant_labels)
		)


func _get_leftmost_item_tab_controls() -> Array[Node]:
	if not _items.get_item_labels().is_empty():
		return _items.get_item_labels()
	return _items.get_rank_labels()


## Sets a label's text to a float.
func _set_label_text_to_number(label: Label, num: float) -> void:
	label.text = Utilities.float_to_string(num, true)


## Moves the status screen to indicate switching units.
func _move(dir_multiplier: int) -> void:
	_scroll_lock = true
	const DURATION: float = 0.32
	var menu := $MenuScreen as HBoxContainer
	var dest: float = menu.size.y
	const SWAP_THRESHOLD: float = 1.0 / 3
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/status_swap.ogg"))
	var destination: float = dest * SWAP_THRESHOLD * dir_multiplier

	await _create_fade_tween(menu, destination, 0, DURATION / 2).finished

	menu.position.y = -destination
	_update()

	await _create_fade_tween(menu, 0, 1, DURATION / 2).finished

	menu.position.y = 0
	_scroll_lock = false


func _create_fade_tween(
	menu: HBoxContainer, new_y: float, new_alpha: float, duration: float
) -> Tween:
	var fade_in: Tween = create_tween()
	fade_in.set_speed_scale(2)
	fade_in.set_parallel(true)
	fade_in.tween_property(menu, ^"position:y", new_y, duration)
	fade_in.tween_property(menu, ^"modulate:a", new_alpha, duration)
	return fade_in
