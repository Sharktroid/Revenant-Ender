class_name HelpContainer
extends BoxContainer

@export_multiline var help_description: String
var help_table: Table

var selectable: bool = true


func _enter_tree() -> void:
	mouse_entered.connect(_on_mouse_entered)


func _gui_input(event: InputEvent) -> void:
	if (
		((event.is_action_pressed("select") and selectable) or event.is_action_pressed("status"))
		and not HelpPopupController.is_active()
	):
		set_as_current_help_container()
		AudioPlayer.play_sound_effect(preload("res://audio/sfx/help_open.ogg"))


func set_as_current_help_container() -> void:
	var nodes: Array[Control] = []
	if help_description.length() > 0:
		nodes.append(HelpPopupController.create_text_node(help_description))
	if help_table:
		nodes.insert(0, help_table.to_grid_container())
	HelpPopupController.set_help_nodes(
		[nodes], global_position + Vector2(size.x / 2, 0).round(), self
	)


func _on_mouse_entered() -> void:
	if HelpPopupController.is_active():
		set_as_current_help_container()
