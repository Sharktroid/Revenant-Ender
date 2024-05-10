extends Control

var old_level: int = 1
var unit: Unit


func _ready() -> void:
	var children := $Children as Control
	children.visible = false
	const TRACK: AudioStreamOggVorbis = preload("res://audio/music/level_up!.ogg")
	AudioPlayer.play_track(TRACK)
	var track_timer: SceneTreeTimer = get_tree().create_timer(TRACK.loop_offset - 10.0 / 60)
	await track_timer.timeout

	#region initialization
	var left_panel := %Left as PanelContainer
	var right_panel := %Right as PanelContainer
	var max_width: float = ceilf(maxf(left_panel.size.x, right_panel.size.x) / 16) * 16
	left_panel.custom_minimum_size.x = max_width
	right_panel.custom_minimum_size.x = max_width

	(%ClassName as Label).text = unit.unit_name
	var level_value := %LevelValue as Label
	level_value.text = str(old_level)

	var stat_containers: Dictionary = {}
	for control: Control in (
		left_panel.get_child(0).get_children() + right_panel.get_child(0).get_children()
	):
		stat_containers[control.name] = control
	for stat_name: String in Unit.Stats.keys():
		var formatted_stat: String = stat_name.to_pascal_case()
		var stat: Unit.Stats = Unit.Stats[stat_name]
		var old_stat: int = unit.get_stat(stat, old_level)
		(get_node("%%%sValue" % formatted_stat) as Label).text = str(old_stat)
	#endregion

	children.visible = true
	GameController.add_to_input_stack(self)
	var top_panel := %TopPanel as PanelContainer
	var bottom_panel := %BottomPanel as PanelContainer
	var slide_tween: Tween = create_tween()
	slide_tween.set_parallel()
	slide_tween.set_trans(Tween.TRANS_QUAD)
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.tween_property(top_panel, "position:x", top_panel.position.x, 8.0 / 60)
	(
		slide_tween
		.tween_property(bottom_panel, "position:x", bottom_panel.position.x, 8.0 / 60)
		.set_delay(2.0 / 60)
	)
	top_panel.position.x = -top_panel.size.x
	bottom_panel.position.x = -bottom_panel.size.x
	await get_tree().create_timer(35.0 / 60).timeout

	level_value.text = str(unit.level)
	const Sparkle = preload("res://ui/level_up_screen/spiral_sparkle.gd")
	(%LevelSparkle as Sparkle).play()
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/level_up_level_blip.ogg"))
	await get_tree().create_timer(20.0 / 60).timeout

	var stat_order: Array[Unit.Stats] = [
		Unit.Stats.HIT_POINTS,
		Unit.Stats.STRENGTH,
		Unit.Stats.PIERCE,
		Unit.Stats.INTELLIGENCE,
		Unit.Stats.SKILL,
		Unit.Stats.SPEED,
		Unit.Stats.MOVEMENT,
		Unit.Stats.DEFENSE,
		Unit.Stats.ARMOR,
		Unit.Stats.RESISTANCE,
		Unit.Stats.LUCK,
		Unit.Stats.BUILD
	]
	for stat: Unit.Stats in stat_order:
		var old_stat: int = unit.get_stat(stat, old_level)
		var current_stat: int = unit.get_stat(stat, unit.level)
		var stat_name := (Unit.Stats as Dictionary).find_key(stat) as String
		var formatted_stat: String = stat_name.to_pascal_case()
		var stat_container: Control = stat_containers["%sContainer" % formatted_stat]
		(get_node("%%%sValue" % formatted_stat) as Label).text = str(current_stat)

		var difference: int = current_stat - old_stat
		if difference != 0:
			AudioPlayer.play_sound_effect(preload("res://audio/sfx/level_up_blip.ogg"))
			const StatChange = preload("res://ui/level_up_screen/stat_change.gd")
			(%StatChanges.get_node("%sChange" % formatted_stat) as StatChange).value = difference

			var panel := stat_container.get_node("Panel") as Panel
			panel.visible = true
			var panel_tween: Tween = create_tween()
			panel_tween.set_parallel()
			panel_tween.tween_property(panel, "size:x", panel.size.x, 4.0 / 60)
			panel_tween.tween_property(panel, "position:x", panel.position.x, 4.0 / 60)
			panel.position.x += panel.size.x / 2
			panel.size.x = 0

			(%Sparkles.get_node("%sSparkle" % formatted_stat) as Sparkle).play()

			await get_tree().create_timer(20.0 / 60).timeout
	await get_tree().create_timer(1.0).timeout


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioPlayer.stop_and_resume_previous_track()
		queue_free()
