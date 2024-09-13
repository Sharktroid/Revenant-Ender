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
## When >0, tab switching is disabled. Decreases by one each tick.
var _delay: int = 0
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
	GameController.add_to_input_stack(self)

	_update.call_deferred()

	(%AttackLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.ATTACK
	(%ASLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.ATTACK_SPEED
	(%HitLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.HIT
	(%AvoidLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.AVOID
	(%CritLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.CRIT
	(%DodgeLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.DODGE


func _physics_process(_delta: float) -> void:
	_delay -= 1


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


func _receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
	if _delay <= 0:
		if event.is_action_pressed("left", true) and not Input.is_action_pressed("right"):
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.TAB_SWITCH)
			Utilities.switch_tab(_menu_tabs as TabContainer, -1)
			_delay = 5
		elif event.is_action_pressed("right", true):
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.TAB_SWITCH)
			Utilities.switch_tab(_menu_tabs as TabContainer, 1)
			_delay = 5
	if not _scroll_lock:
		if Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
			observing_unit = MapController.map.get_previous_unit(observing_unit)
			_move(_Directions.UP)
		elif Input.is_action_pressed("down"):
			observing_unit = MapController.map.get_next_unit(observing_unit)
			_move(_Directions.DOWN)


## Updates internal variables
func _update() -> void:
	_statistics.observing_unit = observing_unit
	_items.observing_unit = observing_unit

	var old_portrait: Portrait = _portrait
	var new_portrait: Portrait = observing_unit.get_portrait()
	new_portrait.position = observing_unit.get_portrait_offset()
	old_portrait.replace_by(new_portrait)
	new_portrait.set_emotion(Portrait.Emotions.NONE)
	_portrait = new_portrait
	old_portrait.queue_free()

	(%UnitName as Label).text = observing_unit.display_name
	(%UnitDescription as HelpContainer).help_description = observing_unit.unit_description

	(%ClassName as Label).text = observing_unit.unit_class.resource_name
	(%ClassDescription as HelpContainer).help_description = (
		observing_unit.unit_class.get_description()
	)

	_set_label_text_to_number(%CurrentLevel as Label, observing_unit.level)
	_set_label_text_to_number(%MaxLevel as Label, observing_unit.MAX_LEVEL)

	_set_label_text_to_number(%Current as Label, roundi(observing_unit.current_health))
	_set_label_text_to_number(%MaxHitPoints as Label, observing_unit.get_hit_points())

	var current_exp: float = observing_unit.get_current_exp()
	var next_level_exp: float = Unit.get_exp_to_level(observing_unit.level + 1)
	_set_label_text_to_number(%EXPPercent as Label, observing_unit.get_exp_percent())

	var exp_description: String = (
		"[center][color={blue}]{current_exp}[color={yellow}]/"
		+ "[/color]{next_level_exp}[/color][/center]\n"
		+ "[color={blue}]{remaining_exp}[/color] to next level\n"
		+ "Total exp: [color={blue}]{total_exp}[/color]"
	)
	var replacements: Dictionary = {
		"blue": Utilities.font_blue,
		"yellow": Utilities.font_yellow,
		"current_exp": roundi(current_exp),
		"next_level_exp": roundi(next_level_exp),
		"remaining_exp": roundi(next_level_exp - current_exp),
		"total_exp": roundi(observing_unit.total_exp),
	}
	(%EXPStatHelp as HelpContainer).help_description = (exp_description.format(replacements))

	var attack_description := %AttackDescription as HelpContainer
	var attack_label := %AttackValue as Label
	var hit_description := %HitDescription as HelpContainer
	var hit_label := %HitValue as Label
	var crit_description := %CritDescription as HelpContainer
	var crit_label := %CritValue as Label

	if observing_unit.get_current_weapon():
		attack_description.help_description = ("{attack} + {might}".format(
			{
				"attack": observing_unit.get_current_attack(),
				"might": observing_unit.get_current_weapon().get_might()
			}
		))
		_set_label_text_to_number(attack_label, observing_unit.get_attack())

		hit_description.help_description = Formulas.HIT.format(observing_unit)
		_set_label_text_to_number(hit_label, observing_unit.get_hit())

		crit_description.help_description = Formulas.CRIT.format(observing_unit)
		_set_label_text_to_number(crit_label, observing_unit.get_crit())
	else:
		attack_description.help_description = "--"
		attack_label.text = "--"

		hit_description.help_description = "--"
		hit_label.text = "--"

		crit_description.help_description = "--"
		crit_label.text = "--"

	(%ASDescription as HelpContainer).help_description = Formulas.ATTACK_SPEED.format(
		observing_unit
	)
	_set_label_text_to_number(%ASValue as Label, observing_unit.get_attack_speed())

	(%AvoidDescription as HelpContainer).help_description = Formulas.AVOID.format(observing_unit)
	_set_label_text_to_number(%AvoidValue as Label, observing_unit.get_avoid())

	(%DodgeDescription as HelpContainer).help_description = Formulas.DODGE.format(observing_unit)
	_set_label_text_to_number(%DodgeValue as Label, observing_unit.get_dodge())

	var current_weapon: Weapon = observing_unit.get_current_weapon()
	var range_value := %RangeValue as RichTextLabel
	var range_text: String = current_weapon.get_range_text().replace(
		"-", " [color={yellow}]-[/color] ".format({"yellow": Utilities.font_yellow})
	)
	range_value.text = ("[color={blue}]{text}[/color]".format(
		{"blue": Utilities.font_blue, "text": range_text}
	))

	_update_tab()

	var hp_help := %HitPointsStatHelp as HelpContainer
	hp_help.help_table = observing_unit.get_stat_table(Unit.Stats.HIT_POINTS)
	hp_help.table_columns = 4


## Updates the current tab.
func _update_tab() -> void:
	var constant_labels: Array[Control] = [%UnitDescription]
	for child: Node in %HighStatsContainer.get_children():
		constant_labels.append(child if child is HelpContainer else child.get_child(1))
	var tab_controls: Array[Control] = []
	match _menu_tabs.current_tab:
		0:
			tab_controls.assign(_statistics.get_left_controls())
		1:
			tab_controls.assign(
				(
					_items.get_item_labels()
					if not _items.get_item_labels().is_empty()
					else _items.get_rank_labels()
				)
			)
	await get_tree().process_frame
	for control: Control in constant_labels:
		var matching_control: Control = Utilities.get_control_within_height(control, tab_controls)
		control.focus_neighbor_right = control.get_path_to(matching_control)
	for control: Control in tab_controls:
		var matching_control: Control = Utilities.get_control_within_height(
			control, constant_labels
		)
		control.focus_neighbor_left = control.get_path_to(matching_control)


## Sets a label's text to a float.
func _set_label_text_to_number(label: Label, num: float) -> void:
	label.text = Utilities.float_to_string(num)


## Moves the status screen to indicate switching units.
func _move(dir: _Directions) -> void:
	_scroll_lock = true
	const DURATION: float = 0.32
	var menu := $MenuScreen as HBoxContainer
	var dest: float = menu.size.y
	const SWAP_THRESHOLD: float = 1.0 / 3
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/status_swap.ogg"))
	var dir_multiplier: int = -1 if dir == _Directions.DOWN else 1

	var fade_out: Tween = create_tween()
	fade_out.set_speed_scale(2)
	fade_out.set_parallel(true)
	fade_out.tween_property(
		menu, "position:y", dest * SWAP_THRESHOLD * dir_multiplier, DURATION / 2
	)
	fade_out.tween_property(menu, "modulate:a", 0, DURATION / 2)
	await fade_out.finished

	menu.position.y = -dest * SWAP_THRESHOLD * dir_multiplier
	_update()

	var fade_in: Tween = create_tween()
	fade_in.set_speed_scale(2)
	fade_in.set_parallel(true)
	fade_in.tween_property(menu, "position:y", 0, DURATION / 2)
	fade_in.tween_property(menu, "modulate:a", 1, DURATION / 2)
	await fade_in.finished

	menu.position.y = 0
	_scroll_lock = false


## Called when menu tab is changed.
func _on_menu_tabs_tab_changed(_tab: int) -> void:
	_update_tab()
	HelpPopupController.shrink()
