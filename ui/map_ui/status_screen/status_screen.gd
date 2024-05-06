extends Control

var observing_unit := Unit.new()

var _scroll_lock: bool = false
@onready var _portrait := %Portrait as Portrait
@onready var _menu_tabs := $"Menu Screen/Menu Tabs" as TabContainer
var _delay: int = 0

static var previous_tab: int = 0


func _ready() -> void:
	_menu_tabs.current_tab = previous_tab
	(_menu_tabs.get_child(0, true) as TabBar).mouse_filter = Control.MOUSE_FILTER_PASS
	GameController.add_to_input_stack(self)

	_update.call_deferred()


func _physics_process(_delta: float) -> void:
	_delay -= 1


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
	if _delay <= 0:
		if event.is_action_pressed("left", true) and not Input.is_action_pressed("right"):
			Utilities.switch_tab(_menu_tabs as TabContainer, -1)
			_delay = 5
		elif event.is_action_pressed("right", true):
			Utilities.switch_tab(_menu_tabs as TabContainer, 1)
			_delay = 5
	elif not _scroll_lock:
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


func _update() -> void:
	var old_portrait: Portrait = _portrait
	var new_portrait: Portrait = observing_unit.get_portrait()
	new_portrait.position = observing_unit.get_portrait_offset()
	old_portrait.replace_by(new_portrait)
	new_portrait.set_emotion(Portrait.emotions.NONE)
	_portrait = new_portrait
	old_portrait.queue_free()

	(%"Unit Name" as Label).text = observing_unit.unit_name
	(%"Unit Description" as HelpContainer).help_description = observing_unit.unit_description

	(%"Class Name" as Label).text = observing_unit.unit_class.name
	(%"Class Description" as HelpContainer).help_description = observing_unit.unit_class.description

	_set_label_text_to_number(%"Current Level" as Label, observing_unit.level)
	_set_label_text_to_number(%"Max Level" as Label, observing_unit.get_max_level())

	_set_label_text_to_number(%"Current HP" as Label, roundi(observing_unit.current_health))
	_set_label_text_to_number(%"Max HP" as Label, observing_unit.get_stat(Unit.stats.HIT_POINTS))

	var current_exp: float = observing_unit.get_current_exp()
	var next_level_exp: float = Unit.get_exp_to_level(observing_unit.level + 1)
	_set_label_text_to_number(%"Exp Percent" as Label, observing_unit.get_exp_percent())
	(%"Exp Stat Help" as HelpContainer).help_description = \
			"%d/%d\n%d to next level\nTotal exp: %d" % [
				roundi(current_exp),
				roundi(next_level_exp),
				roundi(next_level_exp - current_exp),
				roundi(observing_unit.total_exp)
			]

	var attack_description := %"Attack Description" as HelpContainer
	var attack_label := %"Attack Value" as Label
	var hit_description := %"Hit Description" as HelpContainer
	var hit_label := %"Hit Value" as Label
	var crit_description := %"Crit Description" as HelpContainer
	var crit_label := %"Crit Value" as Label
	if observing_unit.get_current_weapon():
		attack_description.help_description = "%d + %d" % [
				observing_unit.get_raw_attack() - observing_unit.get_current_weapon().might,
				observing_unit.get_current_weapon().might]
		_set_label_text_to_number(attack_label, observing_unit.get_raw_attack())

		hit_description.help_description = "%d + %d * 2 + %d" % [
				observing_unit.get_current_weapon().hit,
				observing_unit.get_stat(Unit.stats.SKILL), observing_unit.get_stat(Unit.stats.LUCK)]
		_set_label_text_to_number(hit_label, observing_unit.get_hit())

		crit_description.help_description = "%d + %d" % [
				observing_unit.get_current_weapon().crit,
				observing_unit.get_stat(Unit.stats.SKILL)]
		_set_label_text_to_number(crit_label, observing_unit.get_crit())
	else:
		attack_description.help_description = "--"
		attack_label.text = "--"

		hit_description.help_description = "--"
		hit_label.text = "--"

		crit_description.help_description = "--"
		crit_label.text = "--"

	(%"AS Description" as HelpContainer).help_description = \
			"%d - %d" % [observing_unit.get_stat(Unit.stats.SPEED),
			observing_unit.get_stat(Unit.stats.SPEED) - observing_unit.get_attack_speed()]
	_set_label_text_to_number(%"AS Value" as Label, observing_unit.get_attack_speed())

	(%"Avoid Description" as HelpContainer).help_description = \
			"%d * 2 + %d" % [observing_unit.get_attack_speed(),
			observing_unit.get_stat(Unit.stats.LUCK)]
	_set_label_text_to_number(%"Avoid Value" as Label, observing_unit.get_avoid())

	(%"Crit Avoid Description" as HelpContainer).help_description = \
			"%d" % [observing_unit.get_stat(Unit.stats.LUCK)]
	_set_label_text_to_number(%"Crit Avoid Value" as Label, observing_unit.get_crit_avoid())

	var current_weapon := observing_unit.get_current_weapon()
	var min_range := %"Min Range" as Label
	var range_separator := %"Range Separator" as Label
	var max_range := %"Max Range" as Label
	if current_weapon:
		_set_label_text_to_number(min_range, current_weapon.min_range)
		if current_weapon.min_range == current_weapon.max_range:
			range_separator.visible = false
			max_range.visible = false
		else:
			range_separator.visible = true
			max_range.visible = true
			_set_label_text_to_number(max_range, current_weapon.max_range)
	else:
		min_range.text = "--"
		range_separator.visible = false
		max_range.text = ""

	_update_tab()

	var hp_help := %"HP Stat Help" as HelpContainer
	hp_help.help_table = observing_unit.get_stat_table(Unit.stats.HIT_POINTS)
	hp_help.table_columns = 4


func _update_tab() -> void:
	var constant_labels: Array[Control] = [%"Unit Description"]
	for child: Node in %"High Stats Container".get_children():
		constant_labels.append(child if child is HelpContainer else child.get_child(1))
	var tab_controls: Array[Control] = []
	match _menu_tabs.current_tab:
		0:
			const Statistics = preload("res://ui/map_ui/status_screen/statistics/statistics.gd")
			var statistics := $"Menu Screen/Menu Tabs/Statistics" as Statistics
			statistics.observing_unit = observing_unit
			statistics.update()
			tab_controls.assign(statistics.get_left_controls())
		1:
			const ItemScreen = preload("res://ui/map_ui/status_screen/item_screen/item_screen.gd")
			var items := $"Menu Screen/Menu Tabs/Items" as ItemScreen
			items.observing_unit = observing_unit
			items.update()
			tab_controls.assign(items.get_item_labels())
	await get_tree().process_frame
	for control: Control in constant_labels:
		var nodes: Array[Node] = []
		nodes.assign(tab_controls)
		var matching_control: Control = Utilities.get_control_within_height(control, nodes)
		control.focus_neighbor_right = control.get_path_to(matching_control)
	for control: Control in tab_controls:
		var nodes: Array[Node] = []
		nodes.assign(constant_labels)
		var matching_control: Control = Utilities.get_control_within_height(control, nodes)
		control.focus_neighbor_left = control.get_path_to(matching_control)


func _set_label_text_to_number(label: Label, num: int) -> void:
	label.text = str(num)


func _move(dir: int) -> void:
	_scroll_lock = true
	const DURATION = 1.0/6
	var menu := $"Menu Screen" as HBoxContainer
	var dest: float = menu.size.y
	const SWAP_THRESHOLD: float = 1.0/3

	var fade_out: Tween = create_tween()
	fade_out.set_speed_scale(2)
	fade_out.set_parallel(true)
	fade_out.tween_property(menu, "position:y", dest * SWAP_THRESHOLD * dir, DURATION)
	fade_out.tween_property(menu, "modulate:a", 0, DURATION)
	await fade_out.finished

	menu.position.y = -dest * dir * SWAP_THRESHOLD
	_update()

	var fade_in: Tween = create_tween()
	fade_in.set_speed_scale(2)
	fade_in.set_parallel(true)
	fade_in.tween_property(menu, "position:y", 0, DURATION)
	fade_in.tween_property(menu, "modulate:a", 1, DURATION)
	await fade_in.finished

	menu.position.y = 0
	_scroll_lock = false


func _on_menu_tabs_tab_changed(_tab: int) -> void:
	_update_tab()
	HelpPopupController.shrink()
