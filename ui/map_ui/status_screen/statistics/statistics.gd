extends Control

var observing_unit: Unit


func update() -> void:
	var offensive_labels := %OffensiveLabels as VBoxContainer
	var defensive_labels := %DefensiveLabels as VBoxContainer
	var misc_labels := %MiscLabels as VBoxContainer
	var other_labels := %OtherLabels as VBoxContainer
	var max_width: int = (
		[
			roundi(offensive_labels.size.x),
			roundi(defensive_labels.size.x),
			roundi(misc_labels.size.x),
			roundi(other_labels.size.x)
		]
		.max()
	)
	offensive_labels.custom_minimum_size.x = max_width
	defensive_labels.custom_minimum_size.x = max_width
	misc_labels.custom_minimum_size.x = max_width
	other_labels.custom_minimum_size.x = max_width

	_update_stat_bar(%StrengthBar as StatBar, Unit.Stats.STRENGTH)
	_update_stat_bar(%PierceBar as StatBar, Unit.Stats.PIERCE)
	_update_stat_bar(%IntelligenceBar as StatBar, Unit.Stats.INTELLIGENCE)
	_update_stat_bar(%DefenseBar as StatBar, Unit.Stats.DEFENSE)
	_update_stat_bar(%ArmorBar as StatBar, Unit.Stats.ARMOR)
	_update_stat_bar(%ResistanceBar as StatBar, Unit.Stats.RESISTANCE)
	_update_stat_bar(%DexterityBar as StatBar, Unit.Stats.DEXTERITY)
	_update_stat_bar(%SpeedBar as StatBar, Unit.Stats.SPEED)
	_update_stat_bar(%LuckBar as StatBar, Unit.Stats.LUCK)
	_update_stat_bar(%BuildBar as StatBar, Unit.Stats.BUILD)
	_update_stat_bar(%MovementBar as StatBar, Unit.Stats.MOVEMENT)

	(%WeightValue as Label).text = str(observing_unit.get_weight())
	var aid_value := %AidValue as Label
	aid_value.text = "-" if observing_unit.get_aid() < 0 else str(observing_unit.get_aid())
	const StarsLabel = preload(
		"res://ui/map_ui/status_screen/statistics/stars_label/stars_label.gd"
	)
	(%AuthorityStars as StarsLabel).stars = observing_unit.get_authority()
	(%TravelerName as Label).text = (
		observing_unit.traveler.name as String if observing_unit.traveler else "-"
	)

	(%WeightNumber as HelpContainer).help_description = ("{build} + {weight_modifier}".format({
		"build": observing_unit.get_build(),
		"weight_modifier": observing_unit.unit_class.get_weight_modifier()
	}))
	var aid_number := %AidNumber as HelpContainer
	var aid_description: String = _get_unformatted_aid_description(
		observing_unit.unit_class.get_aid_modifier()
	)
	aid_number.help_description = aid_description.format({
		"build": observing_unit.get_build(),
		"aid_modifier": absi(observing_unit.unit_class.get_aid_modifier())
	})


func get_left_controls() -> Array[Node]:
	return get_tree().get_nodes_in_group("left_nodes")


func _update_stat_bar(stat_bar: StatBar, stat: Unit.Stats) -> void:
	stat_bar.unit = observing_unit
	stat_bar.stat = stat
	stat_bar.update.call_deferred()


func _get_unformatted_aid_description(aid_modifier: int) -> String:
	match sign(aid_modifier):
		1:
			return "{aid_modifier} - {build}"
		-1:
			return "{build} - {aid_modifier}"
		_:
			return "{build} + 0"
