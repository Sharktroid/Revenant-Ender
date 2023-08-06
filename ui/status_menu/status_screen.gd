extends Control


func _ready() -> void:
	grab_focus()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()


func _has_point(_point: Vector2) -> bool:
	return true


func close() -> void:
	queue_free()
