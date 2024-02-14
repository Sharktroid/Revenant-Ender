class_name HelpContainer
extends BoxContainer


@export_multiline var help_description: String

var selectable: bool = true


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)


func _gui_input(event: InputEvent) -> void:
	if (((event.is_action_pressed("ui_select") and selectable)
			or (event.is_action_pressed("status")))
			and not HelpPopupController.is_active()):
		HelpPopupController.display_text(help_description, _get_popup_offset())


func _on_mouse_entered() -> void:
	if HelpPopupController.is_active():
		HelpPopupController.display_text(help_description, _get_popup_offset())


func _get_popup_offset() -> Vector2i:
	var pos: Vector2 = global_position + Vector2(size.x/2, 0).round()
	var v_size: int = roundi(size.y)
	var popup_size: Vector2 = HelpPopupController.get_node_size(help_description)
	if v_size + pos.y + popup_size.y > Utilities.get_screen_size().y:
		pos.y -= popup_size.y
	else:
		pos.y += v_size
	pos.x = clampf(pos.x, float(popup_size.x)/2,
			Utilities.get_screen_size().x - float(popup_size.x)/2)
	return pos
