extends Control


var old_level: int = 1
var unit: Unit


func _ready() -> void:
	var children := $Children as Control
	children.visible = false
	await ($"Level Up Splash" as Control).tree_exited
	await get_tree().create_timer(0.25).timeout
	children.visible = true
	GameController.add_to_input_stack(self)
	var left_panel := %"Left" as PanelContainer
	var right_panel := %"Right" as PanelContainer
	var max_width: float = ceilf(maxf(left_panel.size.x, right_panel.size.x)/16) * 16
	left_panel.custom_minimum_size.x = max_width
	right_panel.custom_minimum_size.x = max_width

	(%"Class Name" as Label).text = unit.unit_name
	(%"Level Value" as Label).text = str(unit.level)
	var stat_containers: Dictionary = {}
	for control: Control in (left_panel.get_child(0).get_children() +
			right_panel.get_child(0).get_children()):
		stat_containers[control.name] = control
	for stat_name: String in Unit.stats.keys():
		var formatted_stat: String = stat_name.replace("_", " ").capitalize()
		var stat: Unit.stats = Unit.stats[stat_name]
		var old_stat: int = unit.get_stat(stat, old_level)
		var current_stat: int = unit.get_stat(stat, unit.level)
		var stat_container: Control = stat_containers["%s Container" % formatted_stat]
		(get_node("%%%s Value" % formatted_stat) as Label).text = str(current_stat)

		var difference: int = current_stat - old_stat
		var panel := stat_container.get_node("Panel") as Panel
		if difference == 0:
			panel.visible = false
		else:
			panel.visible = true
		const STAT_CHANGE = preload("res://ui/level_up_screen/stat_change.gd")
		(get_node("%%%s Change" % formatted_stat) as STAT_CHANGE).value = difference


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		queue_free()
