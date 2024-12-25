class_name EXPBar
extends ReferenceRect

const _TRANSITION_DURATION: float = 8.0 / 60

var _unit := Unit.new()
@onready var _exp_bar := %EXPBar as ProgressBar


func _ready() -> void:
	_set_visible_ratio(0)


func _process(_delta: float) -> void:
	_exp_bar.value = _unit.get_current_exp()
	_exp_bar.max_value = Unit.get_exp_to_level(_unit.level + 1)
	(%ExpValue as Label).text = "%d%%" % _unit.get_exp_percent()


static func instantiate(observed_unit: Unit, experience: float) -> EXPBar:
	var scene := preload("res://ui/exp_bar/exp_bar.tscn").instantiate() as EXPBar
	scene._unit = observed_unit
	#gdlint: ignore = private-method-call
	scene._play(experience)
	return scene


func _play(experience: float) -> void:
	await ready
	await _display()
	await get_tree().create_timer(0.25).timeout

	var new_exp: float = _unit.total_exp + experience
	var old_level: int = _unit.level
	var tween: Tween = _unit.create_tween()
	tween.tween_property(
		_unit,
		^"total_exp",
		new_exp,
		experience / Unit.get_exp_to_level(ceilf(Unit.get_level_from_exp(new_exp)))
	)
	var exp_audio_player := AudioStreamPlayer.new()
	exp_audio_player.stream = preload("res://audio/sfx/experience.ogg")
	add_child(exp_audio_player)
	exp_audio_player.play()
	await tween.finished
	exp_audio_player.stop()
	exp_audio_player.queue_free()
	await get_tree().create_timer(0.25).timeout
	await _close()

	if _unit.level > old_level:
		await AudioPlayer.pause_track()
		await get_tree().create_timer(0.5).timeout
		var level_up_screen := LevelUpScreen.instantiate(_unit, old_level)
		MapController.get_ui().add_child(level_up_screen)
		await level_up_screen.tree_exited
	queue_free()


func _display() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_visible_ratio, 0.0, 1.0, _TRANSITION_DURATION)
	await tween.finished


func _close() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_visible_ratio, 1.0, 0.0, _TRANSITION_DURATION)
	await tween.finished
	visible = false


func _set_visible_ratio(ratio: float) -> void:
	((%VisibilityPanel as Panel).material as ShaderMaterial).set_shader_parameter(
		"visible_ratio", ratio
	)
