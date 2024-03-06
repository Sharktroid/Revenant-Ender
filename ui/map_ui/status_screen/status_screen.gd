extends Control

var observing_unit := Unit.new()

var _scroll_lock: bool = false
@onready var _portrait: Portrait = %Portrait

static var previous_tab: int = 0


func _enter_tree() -> void:
	$"Menu Screen/Menu Tabs".current_tab = previous_tab
	var internal_tab_bar: TabBar = ($"Menu Screen/Menu Tabs".get_child(0, true))
	internal_tab_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	GameController.add_to_input_stack(self)

	_update.call_deferred()


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
	elif event.is_action_pressed("left") and not event.is_action_pressed("right"):
		Utilities.switch_tab($"Menu Screen/Menu Tabs" as TabContainer, -1)
	elif event.is_action_pressed("right"):
		Utilities.switch_tab($"Menu Screen/Menu Tabs" as TabContainer, 1)
	elif not _scroll_lock:
		if Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
			observing_unit = MapController.map.get_previous_unit(observing_unit)
			_move(1)
		elif Input.is_action_pressed("down"):
			observing_unit = MapController.map.get_next_unit(observing_unit)
			_move(-1)


func close() -> void:
	queue_free()
	previous_tab = $"Menu Screen/Menu Tabs".current_tab
	CursorController.enable()


func _update() -> void:
	var old_portrait: Portrait = _portrait
	var new_portrait: Portrait = observing_unit.get_portrait()
	new_portrait.position = observing_unit.get_portrait_offset()
	old_portrait.replace_by(new_portrait)
	new_portrait.set_emotion(Portrait.emotions.NONE)
	_portrait = new_portrait
	old_portrait.queue_free()

	%"Unit Name".text = observing_unit.unit_name
	%"Unit Description".help_description = observing_unit.unit_description

	%"Class Name".text = observing_unit.unit_class.name
	%"Class Description".help_description = observing_unit.unit_class.description

	_set_label_text_to_number(%"Current Level" as Label, observing_unit.current_level)
	_set_label_text_to_number(%"Max Level" as Label, observing_unit.get_max_level())

	_set_label_text_to_number(%"Current HP" as Label, roundi(observing_unit.get_current_health()))
	_set_label_text_to_number(%"Max HP" as Label, observing_unit.get_stat(Unit.stats.HITPOINTS))

	if observing_unit.get_current_weapon():
		%"Attack Description".help_description = "%d + %d" % [
				observing_unit.get_attack() - observing_unit.get_current_weapon().might,
				observing_unit.get_current_weapon().might]
		_set_label_text_to_number(%"Attack Value" as Label, observing_unit.get_attack())

		%"Hit Description".help_description = "%d + %d * 2 + %d" % [
				observing_unit.get_current_weapon().hit,
				observing_unit.get_stat(Unit.stats.SKILL), observing_unit.get_stat(Unit.stats.LUCK)]
		_set_label_text_to_number(%"Hit Value" as Label, observing_unit.get_hit())

		%"Crit Description".help_description = "%d + %d" % [
				observing_unit.get_current_weapon().crit,
				observing_unit.get_stat(Unit.stats.SKILL)]
		_set_label_text_to_number(%"Crit Value" as Label, observing_unit.get_crit())
	else:
		%"Attack Description".help_description = "--"
		%"Attack Value".text = "--"

		%"Hit Description".help_description = "--"
		%"Hit Value".text = "--"

		%"Crit Description".help_description = "--"
		%"Crit Value".text = "--"

	%"AS Description".help_description = "%d - %d" % [observing_unit.get_stat(Unit.stats.SPEED),
			observing_unit.get_stat(Unit.stats.SPEED) - observing_unit.get_attack_speed()]
	_set_label_text_to_number(%"AS Value" as Label, observing_unit.get_attack_speed())

	%"Avoid Description".help_description = "%d * 2 + %d" % [observing_unit.get_attack_speed(),
			observing_unit.get_stat(Unit.stats.LUCK)]
	_set_label_text_to_number(%"Avoid Value" as Label, observing_unit.get_avoid())

	%"Crit Avoid Description".help_description = "%d" % [observing_unit.get_stat(Unit.stats.LUCK)]
	_set_label_text_to_number(%"Crit Avoid Value" as Label, observing_unit.get_crit_avoid())

	var current_weapon: Weapon = observing_unit.get_current_weapon()
	if current_weapon:
		_set_label_text_to_number(%"Min Range" as Label, current_weapon.min_range)
		if current_weapon.min_range == current_weapon.max_range:
			%"Range Separator".visible = false
			%"Max Range".visible = false
		else:
			%"Range Separator".visible = true
			%"Max Range".visible = true
			_set_label_text_to_number(%"Max Range" as Label, current_weapon.max_range)
	else:
		%"Min Range".text = "--"
		%"Range Separator".visible = false
		%"Max Range".text = ""

	_update_tab()

	%"HP Stat Help".help_table = observing_unit.get_stat_table(Unit.stats.HITPOINTS)
	%"HP Stat Help".table_columns = 4


func _update_tab() -> void:
	var constant_labels: Array[Node] = [%"Unit Description"]
	for child: Control in %"High Stats Container".get_children():
		if child is HelpContainer:
			constant_labels.append(child)
		else:
			constant_labels.append(child.get_child(1))
	var tab_controls: Array[Node]
	match ($"Menu Screen/Menu Tabs" as TabContainer).current_tab:
		0:
			var statistics: Control = $"Menu Screen/Menu Tabs/Statistics"
			statistics.observing_unit = observing_unit
			statistics.update.call_deferred()
			tab_controls = statistics.get_left_controls()
		1:
			var items: Control = $"Menu Screen/Menu Tabs/Items"
			items.observing_unit = observing_unit
			items.update()
			tab_controls = items.get_item_labels()
	await get_tree().process_frame
	for control: Control in constant_labels:
		var matching_control: Control = Utilities.get_control_within_height(control, tab_controls)
		control.focus_neighbor_right = control.get_path_to(matching_control)
	for control: Control in tab_controls:
		var matching_control: Control = Utilities.get_control_within_height(control, constant_labels)
		control.focus_neighbor_left = control.get_path_to(matching_control)


func _set_label_text_to_number(label: Label, num: int) -> void:
	label.text = str(num)


func _move(dir: int) -> void:
	_scroll_lock = true
	const DURATION = 1.0/6
	var dest: float = $"Menu Screen".size.y
	const SWAP_THRESHOLD: float = 1.0/3
	var menu: HBoxContainer = $"Menu Screen"

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
