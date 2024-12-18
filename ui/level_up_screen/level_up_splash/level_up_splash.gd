extends ReferenceRect
@onready var _text_sprite := %TextSprite as Sprite2D

func _ready() -> void:
	var line := $Line as HBoxContainer
	var particle := %Particle as TextureRect
	line.position.x = -particle.size.x
	var line_tween: Tween = create_tween()
	line_tween.tween_property(
		line, ^"size:x", Utilities.get_screen_size().x + particle.size.x * 2, 15.0 / 60
	)
	await line_tween.finished

	await get_tree().create_timer(1.0 / 6).timeout

	line.position.x = 0
	line.size.x = Utilities.get_screen_size().x + particle.size.x
	var percent_height: float = line.anchor_top
	var max_distance_to_edge: int = ceili(
		maxf(percent_height, 1 - percent_height) * Utilities.get_screen_size().y
	)
	var expand_tween: Tween = create_tween()
	var expand_tweener: MethodTweener = expand_tween.tween_method(
		_set_min_size, 0, max_distance_to_edge * 2, 6.0 / 60
	)
	expand_tweener.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var text_tween: Tween = create_tween()
	text_tween.set_loops()
	text_tween.tween_callback(_advance_frame).set_delay(2.0 / 60)
	await get_tree().create_timer(28.0 / 60).timeout
	text_tween.stop()

	_text_sprite.visible = false
	var darken_sprite := %DarkenSprite as Sprite2D
	darken_sprite.visible = true
	var darken_anim_player := darken_sprite.get_node("AnimationPlayer") as AnimationPlayer
	darken_anim_player.play("play")
	await darken_anim_player.animation_finished

	darken_sprite.visible = false
	var fade_sprite := %FadeSprite as Sprite2D
	fade_sprite.visible = true
	var fade_anim_player := fade_sprite.get_node("AnimationPlayer") as AnimationPlayer
	fade_anim_player.play("play")
	await fade_anim_player.animation_finished
	queue_free()


func _set_min_size(value: int) -> void:
	(%Bar as PanelContainer).custom_minimum_size.y = snappedi(value, 2)


func _advance_frame() -> void:
	_text_sprite.frame = 0 if _text_sprite.frame == 12 else _text_sprite.frame + 1
