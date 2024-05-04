extends Control

var observing_unit: Unit


func update() -> void:
	var offensive_labels := %"Offensive Labels" as VBoxContainer
	var defensive_labels := %"Defensive Labels" as VBoxContainer
	var misc_labels := %"Misc Labels" as VBoxContainer
	var other_labels := %"Other Labels" as VBoxContainer
	var max_width: int = [
		roundi(offensive_labels.size.x),
		roundi(defensive_labels.size.x),
		roundi(misc_labels.size.x),
		roundi(other_labels.size.x)].max()
	offensive_labels.custom_minimum_size.x = max_width
	defensive_labels.custom_minimum_size.x = max_width
	misc_labels.custom_minimum_size.x = max_width
	other_labels.custom_minimum_size.x = max_width

	_update_stat_bar(%"Strength Bar" as StatBar, Unit.stats.STRENGTH)
	_update_stat_bar(%"Pierce Bar" as StatBar, Unit.stats.PIERCE)
	_update_stat_bar(%"Magic Bar" as StatBar, Unit.stats.MAGIC)
	_update_stat_bar(%"Defense Bar" as StatBar, Unit.stats.DEFENSE)
	_update_stat_bar(%"Armor Bar" as StatBar, Unit.stats.ARMOR)
	_update_stat_bar(%"Resistance Bar" as StatBar, Unit.stats.RESISTANCE)
	_update_stat_bar(%"Skill Bar" as StatBar, Unit.stats.SKILL)
	_update_stat_bar(%"Speed Bar" as StatBar, Unit.stats.SPEED)
	_update_stat_bar(%"Luck Bar" as StatBar, Unit.stats.LUCK)
	_update_stat_bar(%"Constitution Bar" as StatBar, Unit.stats.CONSTITUTION)
	_update_stat_bar(%"Movement Bar" as StatBar, Unit.stats.MOVEMENT)

	(%"Weight Value" as Label).text = str(observing_unit.get_weight())
	var aid_value := %"Aid Value" as Label
	if observing_unit.get_aid() < 0:
		aid_value.text = "-"
	else:
		aid_value.text = str(observing_unit.get_aid())
	const StarsLabel = preload("res://ui/map_ui/status_screen/statistics/stars_label/stars_label.gd")
	(%"Authority Stars" as StarsLabel).stars = observing_unit.get_authority()
	var traveler_name := %"Traveler Name" as Label
	if observing_unit.traveler:
		traveler_name.text = observing_unit.traveler.name
	else:
		traveler_name.text = "-"

	(%"Weight Number" as HelpContainer).help_description = "%d + %d" % [
		observing_unit.get_stat(Unit.stats.CONSTITUTION),
		observing_unit.unit_class.weight_modifier
	]
	var aid_number := %"Aid Number" as HelpContainer
	if observing_unit.unit_class.aid_modifier < 0:
		aid_number.help_description = "%d - %d" % [
			observing_unit.get_stat(Unit.stats.CONSTITUTION),
			-observing_unit.unit_class.aid_modifier
		]
	elif observing_unit.unit_class.aid_modifier == 0:
		aid_number.help_description = ("%d + 0" %
				[observing_unit.get_stat(Unit.stats.CONSTITUTION)])
	else:
		aid_number.help_description = "%d - %d" % [
			observing_unit.unit_class.aid_modifier,
			observing_unit.get_stat(Unit.stats.CONSTITUTION)
		]


func get_left_controls() -> Array[Node]:
	return (%"Offensive Labels".get_children()
			+ %"Misc Labels".get_children())


func _update_stat_bar(stat_bar: StatBar, stat: Unit.stats) -> void:
	stat_bar.unit = observing_unit
	stat_bar.stat = stat
	stat_bar.update.call_deferred()
