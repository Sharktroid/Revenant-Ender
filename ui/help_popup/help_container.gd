class_name HelpContainer
extends BoxContainer


@export var help_description: String
@export_multiline var help_description: String


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)



func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") and not HelpPopupController.is_active():
		HelpPopupController.display_text(help_description)


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		for c in get_children():
			# Fit to own size
			fit_child_in_rect(c, Rect2(Vector2(), size))


func _on_mouse_entered() -> void:
	if HelpPopupController.is_active():
		HelpPopupController.display_text(help_description)
