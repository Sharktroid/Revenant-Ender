extends Control


var old_level: int = 1
var unit: Unit


func _ready() -> void:
	var children := $Children as Control
	children.visible = false
	await ($"Level Up Splash" as Control).tree_exited
	await get_tree().create_timer(0.25).timeout

	#region initialization
	var left_panel := %"Left" as PanelContainer
	var right_panel := %"Right" as PanelContainer
	var max_width: float = ceilf(maxf(left_panel.size.x, right_panel.size.x)/16) * 16
	left_panel.custom_minimum_size.x = max_width
	right_panel.custom_minimum_size.x = max_width

	(%"Class Name" as Label).text = unit.unit_name
	var level_value := %"Level Value" as Label
	level_value.text = str(old_level)

	var stat_containers: Dictionary = {}
	for control: Control in (left_panel.get_child(0).get_children() +
			right_panel.get_child(0).get_children()):
		stat_containers[control.name] = control
	for stat_name: String in Unit.stats.keys():
		var formatted_stat: String = stat_name.replace("_", " ").capitalize()
		var stat: Unit.stats = Unit.stats[stat_name]
		var old_stat: int = unit.get_stat(stat, old_level)
		(get_node("%%%s Value" % formatted_stat) as Label).text = str(old_stat)
	#endregion

	children.visible = true
	GameController.add_to_input_stack(self)
	var top_panel := %"Top Panel" as PanelContainer
	var bottom_panel := %"Bottom Panel" as PanelContainer
	var slide_tween: Tween = create_tween()
	slide_tween.set_trans(Tween.TRANS_QUAD)
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.tween_property(top_panel, "position:x", top_panel.position.x, 8.0/60)
	slide_tween.parallel().tween_property(bottom_panel,
			"position:x", bottom_panel.position.x, 8.0/60).set_delay(2.0/60)
	top_panel.position.x = -top_panel.size.x
	bottom_panel.position.x = -bottom_panel.size.x
	await slide_tween.finished
	await get_tree().create_timer(35.0/60).timeout

	level_value.text = str(unit.level)
	const SPARKLE = preload("res://ui/level_up_screen/spiral_sparkle.gd")
	(%"Level Sparkle" as SPARKLE).play()
	await get_tree().create_timer(20.0/60).timeout

	var stat_order: Array[Unit.stats] = [Unit.stats.HIT_POINTS, Unit.stats.STRENGTH, Unit.stats.PIERCE,
			Unit.stats.MAGIC, Unit.stats.SKILL, Unit.stats.SPEED, Unit.stats.MOVEMENT,
			Unit.stats.DEFENSE, Unit.stats.ARMOR, Unit.stats.RESISTANCE, Unit.stats.LUCK,
			Unit.stats.CONSTITUTION]
	for stat: Unit.stats in stat_order:
		var old_stat: int = unit.get_stat(stat, old_level)
		var current_stat: int = unit.get_stat(stat, unit.level)
		var stat_name: String = (Unit.stats as Dictionary).find_key(stat)
		var formatted_stat: String = stat_name.replace("_", " ").capitalize()
		var stat_container: Control = stat_containers["%s Container" % formatted_stat]
		(get_node("%%%s Value" % formatted_stat) as Label).text = str(current_stat)

		var difference: int = current_stat - old_stat
		if difference != 0:
			const STAT_CHANGE = preload("res://ui/level_up_screen/stat_change.gd")
			(%"Stat Changes".get_node("%s Change" % formatted_stat) as STAT_CHANGE).value = difference

			var panel := stat_container.get_node("Panel") as Panel
			panel.visible = true
			var panel_tween: Tween = create_tween()
			panel_tween.set_parallel()
			panel_tween.tween_property(panel, "size:x", panel.size.x, 4.0/60)
			panel_tween.tween_property(panel, "position:x", panel.position.x, 4.0/60)
			panel.position.x += panel.size.x/2
			panel.size.x = 0

			(%"Sparkles".get_node("%s Sparkle" % formatted_stat) as SPARKLE).play()

			await get_tree().create_timer(20.0/60).timeout
	await get_tree().create_timer(1.0).timeout


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		queue_free()
