class_name StatusScreen
extends Control

var observing_unit := Unit.new()

var _scroll_lock: bool = false
var _delay: int = 0
@onready var _portrait := %Portrait as Portrait
@onready var _menu_tabs := $MenuScreen/MenuTabs as TabContainer

static var previous_tab: int = 0


func _ready() -> void:
	_menu_tabs.current_tab = previous_tab
	(_menu_tabs.get_child(0, true) as TabBar).mouse_filter = Control.MOUSE_FILTER_PASS
	GameController.add_to_input_stack(self)

	_update.call_deferred()

	(%AttackLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.ATTACK
	(%ASLabelDescription as HelpContainer).help_description += "\n%s" % Formulas.ATTACK_SPEED
	(%HitLabelDescription as HelpContainer).help_description += ("\n%s" % Formulas.HIT)
	(%AvoidLabelDescription as HelpContainer).help_description += ("\n%s" % Formulas.AVOID)
	(%CritLabelDescription as HelpContainer).help_description += ("\n%s" % Formulas.CRIT)
	(%DodgeLabelDescription as HelpContainer).help_description += ("\n%s" % Formulas.DODGE)


func _physics_process(_delta: float) -> void:
	_delay -= 1


static func instantiate(unit: Unit) -> StatusScreen:
	var scene: StatusScreen = (
		preload("res://ui/map_ui/status_screen/status_screen.tscn").instantiate()
	)
	scene.observing_unit = unit
	return scene


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
	if _delay <= 0:
		const TAB_SWITCH: AudioStreamOggVorbis = preload("res://audio/sfx/status_switch.ogg")
		if event.is_action_pressed("left", true) and not Input.is_action_pressed("right"):
			AudioPlayer.play_sound_effect(TAB_SWITCH)
			Utilities.switch_tab(_menu_tabs as TabContainer, -1)
			_delay = 5
		elif event.is_action_pressed("right", true):
			AudioPlayer.play_sound_effect(TAB_SWITCH)
			Utilities.switch_tab(_menu_tabs as TabContainer, 1)
			_delay = 5
	if not _scroll_lock:
		if Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
			observing_unit = MapController.map.get_previous_unit(observing_unit)
			_move(1)
		elif Input.is_action_pressed("down"):
			observing_unit = MapController.map.get_next_unit(observing_unit)
			_move(-1)


func close() -> void:
	queue_free()
	previous_tab = _menu_tabs.current_tab
	CursorController.enable()
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)


func _update() -> void:
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
		"[center][color={blue}]{curr_exp}[color={yellow}]/"
		+ "[/color]{next_level_exp}[/color][/center]\n"
		+ "[color={blue}]{remaining_exp}[/color] to next level\n"
		+ "Total exp: [color={blue}]{total_exp}[/color]"
	)
	(%EXPStatHelp as HelpContainer).help_description = (
		exp_description
		. format(
			{
				"blue": Utilities.font_blue,
				"yellow": Utilities.font_yellow,
				"curr_exp": roundi(current_exp),
				"next_level_exp": roundi(next_level_exp),
				"remaining_exp": roundi(next_level_exp - current_exp),
				"total_exp": roundi(observing_unit.total_exp),
			}
		)
	)

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
		_set_label_text_to_number(attack_label, observing_unit.get_raw_attack())

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


func _update_tab() -> void:
	var constant_labels: Array[Control] = [%UnitDescription]
	for child: Node in %HighStatsContainer.get_children():
		constant_labels.append(child if child is HelpContainer else child.get_child(1))
	var tab_controls: Array[Control] = []
	match _menu_tabs.current_tab:
		0:
			const Statistics = preload("res://ui/map_ui/status_screen/statistics/statistics.gd")
			var statistics := $MenuScreen/MenuTabs/Statistics as Statistics
			statistics.observing_unit = observing_unit
			statistics.update()
			tab_controls.assign(statistics.get_left_controls())
		1:
			const ItemScreen = preload("res://ui/map_ui/status_screen/item_screen/item_screen.gd")
			var items := $MenuScreen/MenuTabs/Items as ItemScreen
			items.observing_unit = observing_unit
			items.update()
			tab_controls.assign(
				(
					items.get_rank_labels()
					if items.get_item_labels().is_empty()
					else items.get_item_labels()
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


func _set_label_text_to_number(label: Label, num: float) -> void:
	label.text = Utilities.float_to_string(num)


func _move(dir: int) -> void:
	_scroll_lock = true
	const DURATION: float = 0.32
	var menu := $MenuScreen as HBoxContainer
	var dest: float = menu.size.y
	const SWAP_THRESHOLD: float = 1.0 / 3
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/status_swap.ogg"))

	var fade_out: Tween = create_tween()
	fade_out.set_speed_scale(2)
	fade_out.set_parallel(true)
	fade_out.tween_property(menu, "position:y", dest * SWAP_THRESHOLD * dir, DURATION / 2)
	fade_out.tween_property(menu, "modulate:a", 0, DURATION / 2)
	await fade_out.finished

	menu.position.y = -dest * dir * SWAP_THRESHOLD
	_update()

	var fade_in: Tween = create_tween()
	fade_in.set_speed_scale(2)
	fade_in.set_parallel(true)
	fade_in.tween_property(menu, "position:y", 0, DURATION / 2)
	fade_in.tween_property(menu, "modulate:a", 1, DURATION / 2)
	await fade_in.finished

	menu.position.y = 0
	_scroll_lock = false


func _on_menu_tabs_tab_changed(_tab: int) -> void:
	_update_tab()
	HelpPopupController.shrink()
