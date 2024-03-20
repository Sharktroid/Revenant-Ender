extends Control

@onready var _canvas_group := $CanvasGroup as CanvasGroup
@onready var _hbox_container := $CanvasGroup/HBoxContainer as HBoxContainer
@onready var _shader_material := _hbox_container.material as ShaderMaterial
@onready var _darken_panel := $"Darken Panel" as Panel


func _ready() -> void:
	_canvas_group.self_modulate.a = 0
	_darken_panel.modulate.a = 0


func play(faction: Faction) -> void:
	AudioPlayer.play_sound_effect(preload("res://audio/sfx/phase_change.ogg"))

	(%"Name Label" as Label).text = faction.name
	var base_color := Color.BLACK
	match faction.color:
		Faction.colors.BLUE: base_color = Color.NAVY_BLUE
		Faction.colors.RED: base_color = Color.DARK_RED
	base_color *= 255

	_shader_material.set_shader_parameter("old_colors", [Color(39, 39, 39, 255)])
	_hbox_container.add_theme_constant_override("separation",
			roundi(float(Utilities.get_screen_size().x)/2))

	var darken_tween: Tween = create_tween()
	darken_tween.tween_property(_darken_panel, "modulate:a", 1, 0.2)
	await get_tree().create_timer(1.0/30).timeout

	var fade_in_tween: Tween = create_tween()
	const SLIDE_DURATION: float = 0.5
	fade_in_tween.tween_property(_hbox_container,
			"theme_override_constants/separation", 3, SLIDE_DURATION)
	fade_in_tween.parallel().tween_property(_canvas_group, "self_modulate:a", 1, SLIDE_DURATION)
	await fade_in_tween.finished

	const COLOR_STAGE: float = 7.0/30
	var running_tween: Tween = create_tween()
	var set_new_color: Callable = func(new_color: Color) -> void:
		_shader_material.set_shader_parameter("new_colors", [new_color])
	running_tween.tween_method(set_new_color, Color(base_color, 0),
			Color(base_color, 255), COLOR_STAGE)
	await running_tween.finished

	await get_tree().create_timer(COLOR_STAGE).timeout

	var color_remove: Tween = create_tween()
	color_remove.tween_method(set_new_color, Color(base_color, 255),
			Color(base_color, 0), COLOR_STAGE)
	await color_remove.finished

	const FADE_OUT: float = 4.0/15
	var fade_out: Tween = create_tween()
	fade_out.tween_property(_canvas_group, "self_modulate:a", 0, FADE_OUT)
	fade_out.parallel().tween_property(_darken_panel, "modulate:a", 0, FADE_OUT)
	await fade_out.finished
