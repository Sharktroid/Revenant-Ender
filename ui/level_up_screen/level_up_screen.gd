class_name LevelUpScreen
extends Control

const _STAT_ORDER: Array[Unit.Stats] = [
	Unit.Stats.HIT_POINTS,
	Unit.Stats.STRENGTH,
	Unit.Stats.PIERCE,
	Unit.Stats.INTELLIGENCE,
	Unit.Stats.DEXTERITY,
	Unit.Stats.SPEED,
	Unit.Stats.MOVEMENT,
	Unit.Stats.DEFENSE,
	Unit.Stats.ARMOR,
	Unit.Stats.RESISTANCE,
	Unit.Stats.LUCK,
	Unit.Stats.BUILD
]
const _SPARKLE = preload("res://ui/level_up_screen/spiral_sparkle.gd")
var _old_level: int = 1
var _unit: Unit


func _ready() -> void:
	var children := $Children as Control
	children.visible = false
	const TRACK: AudioStreamOggVorbis = preload("res://audio/music/level_up!.ogg")
	AudioPlayer.play_track(TRACK)
	await get_tree().create_timer(TRACK.loop_offset - 10.0 / 60).timeout

	_update_panel_side()

	(%ClassName as Label).text = _unit.display_name
	var level_value := %LevelValue as Label
	level_value.text = str(_old_level)

	for stat_name: String in Unit.Stats.keys():
		(get_node("%%%sValue" % stat_name.to_pascal_case()) as Label).text = str(
			_unit.get_stat(Unit.Stats[stat_name] as Unit.Stats, _old_level)
		)

	children.visible = true
	await _animate_slide()

	level_value.text = str(_unit.level)
	(%LevelSparkle as _SPARKLE).play()
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/level_up_level_blip.ogg"))
	await get_tree().create_timer(20.0 / 60).timeout

	await _display_stat_ups()
	await get_tree().create_timer(1.0).timeout


static func instantiate(observing_unit: Unit, level: int) -> LevelUpScreen:
	var scene := (
		preload("res://ui/level_up_screen/level_up_screen.tscn").instantiate() as LevelUpScreen
	)
	scene._unit = observing_unit
	scene._old_level = level
	return scene


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		AudioPlayer.stop_and_resume_previous_track()
		queue_free()


func _animate_slide() -> void:
	var top_panel := %TopPanel as PanelContainer
	var bottom_panel := %BottomPanel as PanelContainer
	var slide_tween: Tween = create_tween()
	slide_tween.set_parallel()
	slide_tween.set_speed_scale(60)
	slide_tween.set_trans(Tween.TRANS_QUAD)
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.tween_property(top_panel, ^"position:x", top_panel.position.x, 8)
	slide_tween.tween_property(bottom_panel, ^"position:x", bottom_panel.position.x, 8).set_delay(2)
	top_panel.position.x = -top_panel.size.x
	bottom_panel.position.x = -bottom_panel.size.x
	await get_tree().create_timer(35.0 / 60).timeout


func _display_stat_ups() -> void:
	var stat_containers: Dictionary[String, Control] = {}
	for control: Control in get_tree().get_nodes_in_group("stats"):
		stat_containers[control.name] = control
	for stat: Unit.Stats in _STAT_ORDER:
		var current_stat: int = _unit.get_stat(stat, _unit.level)
		var formatted_stat: String = (
			((Unit.Stats as Dictionary).find_key(stat) as String).to_pascal_case()
		)
		(get_node("%%%sValue" % formatted_stat) as Label).text = str(current_stat)

		var difference: int = current_stat - _unit.get_stat(stat, _old_level)
		if difference != 0:
			AudioPlayer.play_sound_effect(preload("res://audio/sfx/level_up_blip.ogg"))
			const StatChange = preload("res://ui/level_up_screen/stat_change.gd")
			(%StatChanges.get_node("%sChange" % formatted_stat) as StatChange).value = difference

			var stat_container: Control = stat_containers["%sContainer" % formatted_stat]
			var panel := stat_container.get_node("Panel") as Panel
			panel.visible = true
			var panel_tween: Tween = create_tween()
			panel_tween.set_parallel()
			panel_tween.tween_property(panel, ^"size:x", panel.size.x, 4.0 / 60)
			panel_tween.tween_property(panel, ^"position:x", panel.position.x, 4.0 / 60)
			panel.position.x += panel.size.x / 2
			panel.size.x = 0

			(%Sparkles.get_node("%sSparkle" % formatted_stat) as _SPARKLE).play()

			await get_tree().create_timer(20.0 / 60).timeout

func _update_panel_side() -> void:
	var left_panel := %Left as PanelContainer
	var right_panel := %Right as PanelContainer
	var max_width: float = ceilf(maxf(left_panel.size.x, right_panel.size.x) / 16) * 16
	left_panel.custom_minimum_size.x = max_width
	right_panel.custom_minimum_size.x = max_width
