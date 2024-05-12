extends ReferenceRect

const _TRANSITION_DURATION: float = 8.0 / 60

@onready var _exp_bar := (%EXPBar as ProgressBar)
var observing_unit := Unit.new()


func _ready() -> void:
	_set_visible_ratio(0)


func _process(_delta: float) -> void:
	_exp_bar.value = observing_unit.get_current_exp()
	_exp_bar.max_value = Unit.get_exp_to_level(observing_unit.level + 1)
	(%ExpValue as Label).text = "%d%%" % observing_unit.get_exp_percent()


func play(experience: float) -> void:
	await display()
	await get_tree().create_timer(0.25).timeout

	var new_exp: float = observing_unit.total_exp + experience
	var old_level: int = observing_unit.level
	var tween: Tween = observing_unit.create_tween()
	var duration: float = (
		experience / Unit.get_exp_to_level(ceilf(Unit.get_level_from_exp(new_exp)))
	)
	tween.tween_property(observing_unit, "total_exp", new_exp, duration)
	var exp_audio_player := AudioStreamPlayer.new()
	exp_audio_player.stream = preload("res://audio/sfx/experience.ogg")
	add_child(exp_audio_player)
	exp_audio_player.play()
	await tween.finished
	exp_audio_player.stop()
	exp_audio_player.queue_free()
	await get_tree().create_timer(0.25).timeout
	await close()

	if observing_unit.level > old_level:
		await AudioPlayer.pause_track()
		await get_tree().create_timer(0.5).timeout
		const LVL_UP_PATH = "res://ui/level_up_screen/level_up_screen."
		const LevelUp = preload(LVL_UP_PATH + "gd")
		var level_up_screen := preload(LVL_UP_PATH + "tscn").instantiate() as LevelUp
		level_up_screen.unit = observing_unit
		level_up_screen.old_level = old_level
		MapController.get_ui().add_child(level_up_screen)
		await level_up_screen.tree_exited
		GameController.remove_from_input_stack()
	queue_free()


func display() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_visible_ratio, 0.0, 1.0, _TRANSITION_DURATION)
	await tween.finished


func close() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_visible_ratio, 1.0, 0.0, _TRANSITION_DURATION)
	await tween.finished
	visible = false


func _set_visible_ratio(ratio: float) -> void:
	var shader_material := (%VisibilityPanel as Panel).material as ShaderMaterial
	shader_material.set_shader_parameter("visible_ratio", ratio)
