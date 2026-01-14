extends PanelContainer

@onready var _detailed_stats: Array[HBoxContainer] = [%AttackHBox, %DefenseHBox, %AttackSpeedHBox]


func _ready() -> void:
	for hbox: HBoxContainer in _detailed_stats:
		hbox.visible = true
	for hbox: HBoxContainer in _get_invalid_hboxes():
		hbox.queue_free()


## Updates the stats that are on displayed.
func update(unit: Unit, combat: Combat, distance: int) -> void:
	var weapon: Weapon = unit.get_weapon()
	var in_range: bool = weapon and weapon.in_range(distance)
	var is_attacker: bool = unit == combat.get_attacker()
	_update_hp_display(unit, combat.get_total_damage(false, not(is_attacker)))

	_update_rate_label(%HitLabel as Label, combat.get_hit_rate(unit), in_range)
	_update_rate_label(%CriticalRateLabel as Label, combat.get_crit_rate(unit), in_range)

	if Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.STRATEGIC:
		if in_range:
			_update_total_damage_label(unit, combat, distance)
		else:
			_update_damage_label(%DamageLabel as Label, 0, in_range)
	elif Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.DETAILED:
		##TODO: remove detailed
		pass


func _update_hp_display(unit: Unit, enemy_damage: float) -> void:
	var hp_progress_bar := %HPProgressBar as NumericProgressBar
	hp_progress_bar.max_value = unit.get_hit_points()
	hp_progress_bar.value = maxf(unit.current_health - enemy_damage, 0)
	hp_progress_bar.original_value = unit.current_health
	(%HPLabel as Label).text = Utilities.float_to_string(unit.current_health, true)


func _get_invalid_hboxes() -> Array[HBoxContainer]:
	if Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.STRATEGIC:
		return [%AttackHBox, %DefenseHBox, %AttackSpeedHBox]
	elif Options.COMBAT_PANEL.value == Options.COMBAT_PANEL.DETAILED:
		return [%DamageHBox]
	return []


func _update_damage_label(label: Label, damage: float, in_range: bool) -> void:
	label.text = Utilities.float_to_string(damage, true) if in_range else "--"
	# Put code for effective damage color here.
	label.theme_type_variation = &"BlueLabel" if damage > 0 and in_range else &"GrayLabel"


func _update_rate_label(label: Label, rate: int, in_range: bool) -> void:
	label.text = Utilities.float_to_string(rate, true) if in_range else "--"
	# Put code for effective damage color here.
	var get_type_variation: Callable = func() -> StringName:
		if rate <= 0 or not in_range:
			return &"GrayLabel"
		elif rate >= 100:
			return &"GreenLabel"
		else:
			return &"BlueLabel"
	label.theme_type_variation = get_type_variation.call()


# Gets the theme type variation for the attack speed label.
func _get_attack_speed_label_theme(
	current_unit: Unit, other_unit: Unit, weapon: Weapon, enemy_weapon: Weapon, distance: int
) -> StringName:
	if weapon and weapon.in_range(distance) and enemy_weapon and enemy_weapon.in_range(distance):
		if current_unit.can_follow_up(other_unit):
			return &"GreenLabel"
		elif other_unit.can_follow_up(current_unit):
			return &"GrayLabel"
	return &"BlueLabel"


func _update_total_damage_label(unit: Unit, combat: Combat, distance: int) -> void:
	var is_attacker: bool = unit == combat.get_attacker()
	var total_damage: float = combat.get_total_damage(false, is_attacker)
	var damage_label := %DamageLabel as Label
	damage_label.text = _get_total_damage_string(is_attacker, combat, total_damage)
	damage_label.theme_type_variation = _get_total_damage_type_variation(
		unit, distance, total_damage
	)


func _get_total_damage_string(is_attacker: bool, combat: Combat, total_damage: float) -> String:
	var total_critical_damage: float = combat.get_total_damage(true, is_attacker)
	if total_damage == total_critical_damage:
		return Utilities.float_to_string(total_damage, true)
	else:
		var formatting_replacements: Dictionary[String, String] = {
			"damage": Utilities.float_to_string(total_damage, true),
			"critical_damage": Utilities.float_to_string(total_critical_damage, true)
		}
		return "{damage} ({critical_damage})".format(formatting_replacements)


func _get_total_damage_type_variation(unit: Unit, distance: int, total_damage: float) -> StringName:
	if total_damage > 0 and (unit.get_weapon() and unit.get_weapon().in_range(distance)):
		return &"BlueLabel"
	else:
		return &"GrayLabel"
