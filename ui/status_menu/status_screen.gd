extends Control


func _ready() -> void:
	grab_focus()
	var internal_tab_bar: TabBar = ($"Unit Information Menu/Menu Tabs".get_child(0, true))
	internal_tab_bar.mouse_filter = Control.MOUSE_FILTER_PASS


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()


func _has_point(_point: Vector2) -> bool:
	return true


func close() -> void:
	queue_free()
