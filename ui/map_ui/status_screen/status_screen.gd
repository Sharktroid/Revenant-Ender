extends Control

var observing_unit := Unit.new()

var _scroll_lock: bool = false
@onready var _portrait: Portrait = %Portrait

static var previous_tab: int = 0


func _ready() -> void:
	grab_focus()
	$"Menu Screen/Menu Tabs".current_tab = previous_tab
	var internal_tab_bar: TabBar = ($"Menu Screen/Menu Tabs".get_child(0, true))
	internal_tab_bar.mouse_filter = Control.MOUSE_FILTER_PASS

	_update.call_deferred()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
	elif event.is_action_pressed("left"):
		GenFunc.switch_tab($"Menu Screen/Menu Tabs" as TabContainer, -1)
	elif event.is_action_pressed("right"):
		GenFunc.switch_tab($"Menu Screen/Menu Tabs" as TabContainer, 1)
	elif not _scroll_lock:
		if Input.is_action_pressed("up"):
			observing_unit = MapController.map.get_previous_unit(observing_unit)
			_move(1)
		elif Input.is_action_pressed("down"):
			observing_unit = MapController.map.get_next_unit(observing_unit)
			_move(-1)


func _has_point(_point: Vector2) -> bool:
	return true


func close() -> void:
	MapController.map.grab_focus()
	queue_free()
	previous_tab = $"Menu Screen/Menu Tabs".current_tab


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
		_set_label_text_to_number(%"Attack Value" as Label, observing_unit.get_attack())
	else:
		%"Attack Value".text = "--"
	_set_label_text_to_number(%"AS Value" as Label, observing_unit.get_attack_speed())

	var current_weapon: Weapon = observing_unit.get_current_weapon()
	if current_weapon:
		_set_label_text_to_number(%"Min Range" as Label, current_weapon.min_range)
		if current_weapon.min_range == current_weapon.max_range:
			%"Range Separator".visible = false
			%"Max Range".text = ""
		else:
			%"Range Separator".visible = true
			_set_label_text_to_number(%"Max Range" as Label, current_weapon.max_range)
	else:
		%"Min Range".text = "--"
		%"Range Separator".visible = false
		%"Max Range".text = ""

	$"Menu Screen/Menu Tabs/Statistics".observing_unit = observing_unit
	$"Menu Screen/Menu Tabs/Items".observing_unit = observing_unit

	$"Menu Screen/Menu Tabs/Statistics".update()
	$"Menu Screen/Menu Tabs/Items".update()

	%"HP Stat Help".help_description = observing_unit.get_stat_table(Unit.stats.HITPOINTS)


func _set_label_text_to_number(label: Label, num: int) -> void:
	label.text = str(num)


func _move(dir: int) -> void:
	_scroll_lock = true
	const DURATION = 1.0/6
	var dest: float = $"Menu Screen".size.y
	var fade_threshold: float = 1.0/4
	var swap_threshold: float = 1.0/3
	var get_x: Callable = func() -> float: return $"Menu Screen".position.y * dir
	var velocity: Callable = func():
		var dist: float = $"Menu Screen".size.y * swap_threshold
		return dist * 2 * GenVars.get_frame_delta() * dir / DURATION

	while get_x.call() <= dest * swap_threshold:
		await get_tree().process_frame
		$"Menu Screen".position.y += velocity.call()
		var weight: float = inverse_lerp(0, dest * fade_threshold, get_x.call() as float)
		$"Menu Screen".modulate.a = lerpf(1, 0, weight)

	$"Menu Screen".position.y = -dest * dir * swap_threshold
	_update()

	while get_x.call() < 0:
		await get_tree().process_frame
		$"Menu Screen".position.y += velocity.call()
		var weight: float = inverse_lerp(-dest * fade_threshold, 0, get_x.call() as float)
		$"Menu Screen".modulate.a = lerpf(0, 1, weight)

	$"Menu Screen".position.y = 0
	_scroll_lock = false


func _on_menu_tabs_tab_changed(_tab: int) -> void:
	HelpPopupController.shrink()
