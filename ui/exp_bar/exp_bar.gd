extends Control

const _TRANSITION_DURATION: float = 8.0/60

var observing_unit := Unit.new()


func _ready() -> void:
	_set_visible_ratio(0)


func _process(_delta: float) -> void:
	var progress_bar := %"Exp Bar" as ProgressBar
	progress_bar.value = observing_unit.get_current_experience()


func display() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_visible_ratio, 0.0, 1.0, _TRANSITION_DURATION)
	await tween.finished


func close() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_visible_ratio, 1.0, 0.0, _TRANSITION_DURATION)
	await tween.finished
	queue_free()


func _set_visible_ratio(ratio: float) -> void:
	var shader_material := (%"Visibility Panel" as Panel).material as ShaderMaterial
	shader_material.set_shader_parameter("visible_ratio", ratio)
