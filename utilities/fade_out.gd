class_name FadeOut
extends Node

signal complete

var _duration: float
var _end_alpha: float


func _init(duration: float, end_alpha: float = 0) -> void:
	_duration = duration
	_end_alpha = end_alpha


func _process(delta: float) -> void:
	get_parent().modulate.a -= delta * (1/_duration)
	if get_parent().modulate.a <= _end_alpha:
		emit_signal("complete")
		queue_free()
