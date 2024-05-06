extends Control

var observing_unit: Unit


func update() -> void:
	var offensive_labels := %OffensiveLabels as VBoxContainer
	var defensive_labels := %DefensiveLabels as VBoxContainer
	var misc_labels := %MiscLabels as VBoxContainer
	var other_labels := %OtherLabels as VBoxContainer
	var max_width: int = [
		roundi(offensive_labels.size.x),
		roundi(defensive_labels.size.x),
		roundi(misc_labels.size.x),
		roundi(other_labels.size.x)].max()
	offensive_labels.custom_minimum_size.x = max_width
	defensive_labels.custom_minimum_size.x = max_width
	misc_labels.custom_minimum_size.x = max_width
	other_labels.custom_minimum_size.x = max_width

	_update_stat_bar(%StrengthBar as StatBar, Unit.stats.STRENGTH)
	_update_stat_bar(%PierceBar as StatBar, Unit.stats.PIERCE)
	_update_stat_bar(%MagicBar as StatBar, Unit.stats.MAGIC)
	_update_stat_bar(%DefenseBar as StatBar, Unit.stats.DEFENSE)
	_update_stat_bar(%ArmorBar as StatBar, Unit.stats.ARMOR)
	_update_stat_bar(%ResistanceBar as StatBar, Unit.stats.RESISTANCE)
	_update_stat_bar(%SkillBar as StatBar, Unit.stats.SKILL)
	_update_stat_bar(%SpeedBar as StatBar, Unit.stats.SPEED)
	_update_stat_bar(%LuckBar as StatBar, Unit.stats.LUCK)
	_update_stat_bar(%ConstitutionBar as StatBar, Unit.stats.CONSTITUTION)
	_update_stat_bar(%MovementBar as StatBar, Unit.stats.MOVEMENT)

	(%WeightValue as Label).text = str(observing_unit.get_weight())
	var aid_value := %AidValue as Label
	aid_value.text = "-" if observing_unit.get_aid() < 0 else str(observing_unit.get_aid())
	const StarsLabel = preload("res://ui/map_ui/status_screen/statistics/stars_label/stars_label.gd")
	(%AuthorityStars as StarsLabel).stars = observing_unit.get_authority()
	(%TravelerName as Label).text = (
			observing_unit.traveler.name as String if observing_unit.traveler
			else "-"
	)

	(%WeightNumber as HelpContainer).help_description = "%d + %d" % [
		observing_unit.get_stat(Unit.stats.CONSTITUTION),
		observing_unit.unit_class.weight_modifier
	]
	var aid_number := %AidNumber as HelpContainer
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
	return (%OffensiveLabels.get_children()
			+ %MiscLabels.get_children())


func _update_stat_bar(stat_bar: StatBar, stat: Unit.stats) -> void:
	stat_bar.unit = observing_unit
	stat_bar.stat = stat
	stat_bar.update.call_deferred()
