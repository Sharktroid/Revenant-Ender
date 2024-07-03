class_name PhaseDisplay
extends ReferenceRect

@onready var _canvas_group := $CanvasGroup as CanvasGroup
@onready var _hbox_container := $CanvasGroup/HBoxContainer as HBoxContainer
@onready var _shader_material := _hbox_container.material as ShaderMaterial
@onready var _darken_panel := $DarkenPanel as Panel


static func instantiate(faction: Faction) -> PhaseDisplay:
	var scene := (
		preload("res://maps/phase_display/phase_display.tscn").instantiate() as PhaseDisplay
	)
	scene.play(faction)
	return scene


func play(faction: Faction) -> void:
	await ready
	_canvas_group.self_modulate.a = 0
	_darken_panel.modulate.a = 0
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/phase_change.ogg"))
	(%NameLabel as Label).text = faction.name
	var base_color := Color.BLACK
	match faction.color:
		Faction.Colors.BLUE:
			base_color = Color.NAVY_BLUE
		Faction.Colors.RED:
			base_color = Color.DARK_RED
	_shader_material.set_shader_parameter("old_colors", [Color("272727")])
	_shader_material.set_shader_parameter("new_colors", [Color.TRANSPARENT])
	_hbox_container.add_theme_constant_override(
		"separation", roundi(float(Utilities.get_screen_size().x) / 2)
	)

	var darken_tween: Tween = create_tween()
	darken_tween.tween_property(_darken_panel, "modulate:a", 1, 0.2)
	await get_tree().create_timer(1.0 / 30).timeout

	var fade_in_tween: Tween = create_tween()
	const SLIDE_DURATION: float = 0.5
	var slide_tweener: PropertyTweener = fade_in_tween.tween_property(
		_hbox_container, "theme_override_constants/separation", 3, SLIDE_DURATION
	)
	slide_tweener.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	fade_in_tween.parallel().tween_property(_canvas_group, "self_modulate:a", 1, SLIDE_DURATION)
	await fade_in_tween.finished

	const COLOR_STAGE: float = 7.0 / 30
	var running_tween: Tween = create_tween()
	var set_new_color: Callable = func(new_color: Color) -> void:
		_shader_material.set_shader_parameter("new_colors", [new_color])
	running_tween.tween_method(set_new_color, Color(base_color, 0), Color(base_color), COLOR_STAGE)
	await running_tween.finished

	await get_tree().create_timer(COLOR_STAGE).timeout

	var color_remove: Tween = create_tween()
	color_remove.tween_method(set_new_color, Color(base_color), Color(base_color, 0), COLOR_STAGE)
	await color_remove.finished

	const FADE_OUT: float = 4.0 / 15
	var fade_out: Tween = create_tween()
	fade_out.tween_property(_canvas_group, "self_modulate:a", 0, FADE_OUT)
	fade_out.parallel().tween_property(_darken_panel, "modulate:a", 0, FADE_OUT)
	await fade_out.finished
	queue_free()
